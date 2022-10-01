let
  pname = "lair-keystore";
  version = "0.0.10";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e14f9fb57315f0d4abde222364f19f88c77d2b79.tar.gz") { overlays = [ rust-overlay ]; };
in
nixpkgs.rustPlatform.buildRustPackage rec {
  inherit pname;
  inherit version;

  nativeBuildInputs = [
    (nixpkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
    nixpkgs.perl
  ];

  buildInputs = [ nixpkgs.darwin.apple_sdk.frameworks.AppKit ];

  src = builtins.fetchGit {
    url = "https://github.com/holochain/lair.git";
    rev = "bbb6f43e833f591680ed53b3cde8d9068dbc6780";
  };

  cargoSha256 = "aObOXGYjqK9ExrsnA11Kd4lt2ep1OFbojZubYDmXWmM=";

  doCheck = false;
}
