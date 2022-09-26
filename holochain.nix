let
  pname = "holochain";
  version = "0.0.158";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e14f9fb57315f0d4abde222364f19f88c77d2b79.tar.gz") { overlays = [ rust-overlay ]; };
in
nixpkgs.stdenv.mkDerivation
{
  inherit pname version;

  buildInputs = [
    (nixpkgs.rust-bin.stable."1.60.0".default.override {
      extensions = [ "rust-src" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
    nixpkgs.darwin.apple_sdk.frameworks.AppKit
  ];

  src = builtins.fetchGit
    {
      url = https://github.com/holochain/holochain;
      rev = "0cd777c789ee13ca655f9bffbd7fe11b49e47824";
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
