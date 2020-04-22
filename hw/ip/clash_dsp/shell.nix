{
  nixpkgs ? import <nixpkgs> {}
}:

with nixpkgs;

mkShell {
  name = "audio_effects";
  #shellHook = "cd src; clashi -package ghc-typelits-natnormalise -package ghc-typelits-extra -package ghc-typelits-knownnat -package clash-lib -package clash-prelude -package plotlyhs -package lucid -package microlens -package dsp -package pure-fft -package QuickCheck -package hspec -package HCodecs -fconstraint-solver-iterations=20";
  buildInputs = [

    (pkgs.haskellPackages.ghcWithPackages (p: with p; [
      clash-ghc
      plotlyhs
      lucid
      dsp
      pure-fft
      QuickCheck
      hspec
      HCodecs
    ])
    )
  ];
}
