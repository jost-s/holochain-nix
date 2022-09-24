let
  pname = "holochain";
  version = "0.0.152";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e14f9fb57315f0d4abde222364f19f88c77d2b79.tar.gz") { overlays = [ rust-overlay ]; };
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
      rev = "30f6accd88faa0c2946d63a77d0ba83f82df3a91";
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
