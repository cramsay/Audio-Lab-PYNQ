module ADAU1761 where

import Clash.Prelude
import qualified Clash.Explicit.Prelude as Ex
import qualified Prelude as P

import Data.Maybe (isJust)

import I2S

createDomain vSystem{vName="I2S", vPeriod=hzToPeriod 3e6, vResetPolarity = ActiveLow}
createDomain vSystem{vName="DSP", vPeriod=hzToPeriod 48e6, vResetPolarity = ActiveLow}

i2sToDSP
  :: Clock I2S
  -> Clock DSP
  -> Reset I2S
  -> Reset DSP
  -> Enable I2S
  -> Enable DSP
  -> Signal DSP Bool
  -> Signal I2S (Maybe (Signed 24, Signed 24))
  -> ( Signal DSP (Signed 24, Signed 24)
     , Signal DSP Bool
     , Signal I2S Bool )
i2sToDSP = Ex.asyncFIFOSynchronizer d2

dspToI2S
  :: Clock DSP
  -> Clock I2S
  -> Reset DSP
  -> Reset I2S
  -> Enable DSP
  -> Enable I2S
  -> Signal I2S Bool
  -> Signal DSP (Maybe (Signed 24, Signed 24))
  -> ( Signal I2S (Signed 24, Signed 24)
     , Signal I2S Bool
     , Signal DSP Bool )
dspToI2S = Ex.asyncFIFOSynchronizer d2

{-# ANN topEntity
  (Synthesize
    { t_name   = "i2s_to_stream"
    , t_inputs = [ PortName "clk"
                 , PortName "resetn"
                 , PortName "bclk"
                 , PortName "i2s_rst"
                 , PortName "lrclk"
                 , PortName "si"
                 , PortName "axis_hp_tdata"
                 , PortName "axis_hp_tvalid"
                 , PortName "axis_li_tready"
                 ]
    , t_output = PortProduct "" [PortName "so"
                                ,PortName "axis_hp_tready"
                                ,PortName "axis_li_tdata"
                                ,PortName "axis_li_tvalid"
                                ,PortName "axis_li_tlast"
                                ]
    }) #-}
topEntity
  :: Clock DSP                  -- ^ System clk
  -> Reset DSP                  -- ^ System Reset
  -> Clock I2S                  -- ^ BCLK
  -> Reset I2S                  -- ^ I2S reset signal

  -> Signal I2S Bool            -- ^ LRCLK
  -> Signal I2S Bit             -- ^ SI

  -> Signal DSP (BitVector 48)  -- ^ Headphone data
  -> Signal DSP Bool            -- ^ Headphone valid

  -> Signal DSP Bool            -- ^ Line-in ready

  -> (Signal I2S Bit            -- ^ SO
     ,Signal DSP Bool           -- ^ Headphone ready
     ,Signal DSP (BitVector 48) -- ^ Line-in data
     ,Signal DSP Bool           -- ^ Line-in valid
     ,Signal DSP Bool           -- ^ Line-in "last"
     )
topEntity clk_dsp rst_dsp clk_i2s rst_i2s lrclk_i2s si_i2s hp_data hp_valid li_ready = (so_i2s, hp_ready, li_data, li_valid, li_last)
  where
    enb_i2s = toEnable (pure True) :: Enable I2S
    enb_dsp = toEnable (pure True) :: Enable DSP

    -- i2s in circuit
    mInStereo_i2s = withClockResetEnable clk_i2s rst_i2s enb_i2s i2sIn si_i2s lrclk_i2s
    -- i2s out circuit
    so_i2s = withClockResetEnable clk_i2s rst_i2s enb_i2s i2sOut outStereo_i2s lrclk_i2s

    -- synchroniser circuits
    (li_data', li_empty, _) = i2sToDSP clk_i2s clk_dsp rst_i2s rst_dsp enb_i2s enb_dsp (pure True) mInStereo_i2s --  TODO Note that I removed li_ready and replaced it with pure True here. Is this fix about how we shouldn't wait for ready before going high with valid?
    (outStereo_i2s, _, fullHp_dsp) = dspToI2S clk_dsp clk_i2s rst_dsp rst_i2s enb_dsp enb_i2s newSample_i2s mOutStereo_dsp

    -- Extra logic
    newSample_i2s = isJust <$> mInStereo_i2s

    li_data = ( \x -> (pack $ snd x) ++# (pack $ fst x) ) <$> li_data'
    li_valid = not <$> li_empty

    mOutStereo_dsp = mux (hp_ready .&&. hp_valid)
                     (Just . (\s -> (unpack $ slice d47 d24 s, unpack $ slice d23 d0 s)) <$> hp_data)
                     (pure Nothing)

    hp_ready = not <$> fullHp_dsp

    -- Counting up 2^15 to get ~0.7 seconds per buffer
    sampleCount = Ex.regEn clk_dsp rst_dsp enb_dsp (0 :: Unsigned 15) (li_valid) (sampleCount+1) -- TODO remove li_ready?
    li_last = sampleCount .==. pure maxBound

--tb = filter (snd) . sample $ bundle (li_data, li_valid)
--  where
--  (so, hp_ready, li_data, li_valid, li_last) = topEntity clockGen resetGen clockGen resetGen lrclk si hp_data hp_valid li_ready
--  lrclk = fromList $ P.cycle $ P.replicate 32 False P.++ P.replicate 32 True
--  si    = fromList $ P.concat $ P.map (\a->toList $ vecFromSamples a (negate a)) [1..]
--  hp_data = 0
--  hp_valid = pure False
--  li_ready = pure True

-- Loopback test
tb = Ex.sample so
  where
  (so, hp_ready, li_data, li_valid, li_last) = topEntity clockGen resetGen clockGen resetGen lrclk si hp_data hp_valid li_ready
  lrclk = fromList $ P.cycle $ P.replicate 32 False P.++ P.replicate 32 True
  si    = fromList $ P.concat $ P.map (\a->toList $ vecFromSamples a (negate a)) [1..]
  hp_data = Ex.register clockGen resetGen enableGen 0 li_data
  hp_valid = Ex.register clockGen resetGen enableGen False li_valid
  li_ready = Ex.register clockGen resetGen enableGen False hp_ready

