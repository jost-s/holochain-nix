let
  pname = "holochain";
  version = "0.0.163";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import <nixpkgs> { overlays = [ rust-overlay ]; };
in
nixpkgs.stdenv.mkDerivation
{
  inherit pname version;

  buildInputs = [
    (nixpkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
    nixpkgs.darwin.apple_sdk.frameworks.AppKit
  ];

  src = builtins.fetchGit
    {
      url = https://github.com/holochain/holochain;
      ref = "refs/tags/holochain-${version}";
      rev = "cdcf33ecf0be0a46c0f750be2cab1cf7b0775da7";
    };

  buildPhase = ''
    CARGO_HOME=.cargo cargo build --release --bin holochain --bin hc
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv target/release/holochain $out/bin
    mv target/release/hc $out/bin
  '';

  installCheckPhase = ''
    export PATH="$out/bin:$PATH"
  '';
}
