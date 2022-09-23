let
  pname = "lair-keystore";
  version = "0.0.11";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e14f9fb57315f0d4abde222364f19f88c77d2b79.tar.gz") { overlays = [ rust-overlay ]; };
in
nixpkgs.stdenv.mkDerivation
{
  inherit pname;
  inherit version;

  buildInputs = [
    (nixpkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
    nixpkgs.darwin.apple_sdk.frameworks.AppKit
    nixpkgs.perl
  ];

  src = builtins.fetchGit
    {
      url = https://github.com/holochain/lair.git;
      rev = "840999730ff2a5bacea8a31ed8fbacc954291b5c";
    };

  buildPhase = ''
    CARGO_HOME=.cargo cargo build --release --bin ${pname}
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv target/release/${pname} $out/bin
  '';

  installCheckPhase = ''
    export PATH="$out/bin:$PATH"
  '';
}
