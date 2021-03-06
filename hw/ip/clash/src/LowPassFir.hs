module LowPassFir where

import Clash.Prelude

-- This is straight from clash-lang.org
-- No bit growth, no pipelining. Eep.
fir coeffs x = dotp coeffs (window x)
  where
    dotp as bs = sum (zipWith (*) as bs)

-- Transpose fir with pipelined multipliers
firTranspose coeffs x = foldl delayAdd 0 $
                        zipWith multDelay coeffs'
                        (repeat x)
  where
  delayAdd acc y = delay 0 acc + y
  multDelay y z  = delay 0 (y * z)
  coeffs'        = map pure $ reverse coeffs

-- Designed with http://t-filter.engineerjs.com/
-- 91 taps
lowPass700 = firTranspose coeffs
  where
  coeffs =
    -0.05143163186264108
    :> -0.0043783656813471995
    :> -0.004465225863203685
    :> -0.004486119302522204
    :> -0.004428058264058122
    :> -0.004290376176777752
    :> -0.00406657092001375
    :> -0.0037538525181744107
    :> -0.0033534214360573735
    :> -0.002863533523062421
    :> -0.002281877297408051
    :> -0.0016086920860029954
    :> -0.0008244289575532677
    :> 0.00005623139616744288
    :> 0.000990855786247787
    :> 0.0020533401191838874
    :> 0.0031888723818276465
    :> 0.004406573116832152
    :> 0.005702273168768034
    :> 0.007067509598275266
    :> 0.00849727239531421
    :> 0.009985610239084756
    :> 0.011522349055554907
    :> 0.01309980440224077
    :> 0.014712412496034685
    :> 0.01632904095472642
    :> 0.017977879401011275
    :> 0.019627560687532113
    :> 0.021252991234588868
    :> 0.022868203895256806
    :> 0.024453970556686914
    :> 0.025999782762129577
    :> 0.02749504828914929
    :> 0.02892665364614617
    :> 0.030285278546990875
    :> 0.03156327653062999
    :> 0.03274750950470115
    :> 0.0338259949298171
    :> 0.03486512967402339
    :> 0.03562357214456768
    :> 0.03638745017678461
    :> 0.0370276733568264
    :> 0.0375140853482837
    :> 0.037855848571695806
    :> 0.038056723031967575
    :> 0.038122422324056514
    :> 0.038056723031967575
    :> 0.037855848571695806
    :> 0.0375140853482837
    :> 0.0370276733568264
    :> 0.03638745017678461
    :> 0.03562357214456768
    :> 0.03486512967402339
    :> 0.0338259949298171
    :> 0.03274750950470115
    :> 0.03156327653062999
    :> 0.030285278546990875
    :> 0.02892665364614617
    :> 0.02749504828914929
    :> 0.025999782762129577
    :> 0.024453970556686914
    :> 0.022868203895256806
    :> 0.021252991234588868
    :> 0.019627560687532113
    :> 0.017977879401011275
    :> 0.01632904095472642
    :> 0.014712412496034685
    :> 0.01309980440224077
    :> 0.011522349055554907
    :> 0.009985610239084756
    :> 0.00849727239531421
    :> 0.007067509598275266
    :> 0.005702273168768034
    :> 0.004406573116832152
    :> 0.0031888723818276465
    :> 0.0020533401191838874
    :> 0.000990855786247787
    :> 0.00005623139616744288
    :> -0.0008244289575532677
    :> -0.0016086920860029954
    :> -0.002281877297408051
    :> -0.002863533523062421
    :> -0.0033534214360573735
    :> -0.0037538525181744107
    :> -0.00406657092001375
    :> -0.004290376176777752
    :> -0.004428058264058122
    :> -0.004486119302522204
    :> -0.004465225863203685
    :> -0.0043783656813471995
    :> -0.05143163186264108
    :> Nil

createDomain vXilinxSystem{vName = "AudioDomain", vResetKind = Asynchronous, vResetPolarity = ActiveLow}

unpackChan :: BitVector 48 -> (SFixed 1 23, SFixed 1 23)
unpackChan bv = (left, right)
  where
  left  = unpack $ v2bv (chans !! 1)
  right = unpack $ v2bv (chans !! 0)
  chans = unconcat d24 $ bv2v bv

packChan :: SFixed 1 23 -> SFixed 1 23 -> BitVector 48
packChan left right = pack right ++# pack left

topEntity
  :: Clock AudioDomain
  -> Reset AudioDomain
  -> Signal AudioDomain (BitVector 48)
  -> Signal AudioDomain (Bool)
  -> Signal AudioDomain (Bool)
  -> Signal AudioDomain (Bool)
  -> (Signal AudioDomain (BitVector 48)
     ,Signal AudioDomain Bool
     ,Signal AudioDomain Bool
     ,Signal AudioDomain Bool)
topEntity c r samples v_in last_in r_out = (samples_out, v_in, last_in, r_out)
  where filter = withClockResetEnable c r (toEnable $ v_in .&&. r_out) lowPass700
        (left, right) = unbundle $ unpackChan <$> samples
        samples_out = packChan <$> filter left <*> filter right

{-# ANN topEntity
  (Synthesize
    { t_name   = "clash_lowpass_fir"
    , t_inputs = [ PortName "clk"
                 , PortName "aresetn"
                 , PortName "axis_in_tdata"
                 , PortName "axis_in_tvalid"
                 , PortName "axis_in_tlast"
                 , PortName "axis_out_tready"
                 ]
    , t_output = PortProduct "" [PortName "axis_out_tdata"
                                ,PortName "axis_out_tvalid"
                                ,PortName "axis_out_tlast"
                                ,PortName "axis_in_tready"
                                ]
    }) #-}
