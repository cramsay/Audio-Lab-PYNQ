module I2S (
  i2sIn,
  i2sOut,
  vecFromSamples,
  samplesFromVec
) where

import Clash.Prelude
import qualified Prelude as P

-- I2S input implementation

i2sIn
  :: HiddenClockResetEnable dom
  => Signal dom Bit
  -> Signal dom Bool
  -> Signal dom (Maybe (Signed 24, Signed 24))
i2sIn si lrclk = samples
  where sr = register (replicate d64 low) sr'
        sr' = (<<+) <$> sr <*> si
        isEof = (not <$> lrclk) .&&. delay False lrclk
        samples = mux isEof ((Just . samplesFromVec) <$> sr) (pure Nothing)

samplesFromVec :: Vec 64 Bit -> (Signed 24, Signed 24)
samplesFromVec v = let left  = unpack . v2bv . take d24 $ drop d1  v
                       right = unpack . v2bv . take d24 $ drop d33 v
                   in  (left, right)

-- I2S input implementation

i2sOut
  :: HiddenClockResetEnable dom
  => Signal dom (Signed 24, Signed 24)
  -> Signal dom Bool
  -> Signal dom Bit
i2sOut sample lrclk = (!!) <$> shiftReg <*> counter'
  where
  shiftReg = uncurry vecFromSamples <$> regEn (0,0) isEof sample
  counter = register (0 :: Unsigned 6) counter'
  counter' = mux isEof 0 (counter + 1)
  isEof = (not <$> lrclk) .&&. delay False lrclk

vecFromSamples :: Signed 24 -> Signed 24 -> Vec 64 Bit
vecFromSamples left right =
  low :> (bv2v $ pack left)  ++ replicate d7 low ++
  low :> (bv2v $ pack right) ++ replicate d7 low

-- Testing

simShiftReg = simulate @System (uncurry i2sIn . unbundle) (tbInputs (-42) 999 P.++ tbInputs 0 (-1) P.++ [(low,False)])

tbInputs :: Signed 24 -> Signed 24 -> [(Bit, Bool)]
tbInputs l r = (toList $ zip (fmt l) (repeat False)) P.++
               (toList $ zip (fmt r) (repeat True))
  where fmt x = low :> (bv2v $ pack x) ++ replicate d7 low

simOut = simulate @System (uncurry i2sOut . unbundle) (
    (P.zip (P.repeat (0x88AA11,0xFF7733)) (P.replicate 32 False)) P.++
    (P.zip (P.repeat (0x88AA11,0xFF7733)) (P.replicate 32 True))  P.++
    (P.zip (P.repeat (0x88AA11,0xFF7733)) (P.replicate 32 False)) P.++
    (P.zip (P.repeat (0x88AA11,0xFF7733)) (P.replicate 32 True))
  )

