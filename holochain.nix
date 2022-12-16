let
  pname = "holochain";
  version = "0.1.0-beta-rc.1";
  rust-overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
  nixpkgs = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e14f9fb57315f0d4abde222364f19f88c77d2b79.tar.gz") { overlays = [ rust-overlay ]; };
in
nixpkgs.rustPlatform.buildRustPackage rec {
  inherit pname version;

  nativeBuildInputs = [
    (nixpkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
      targets = [ "wasm32-unknown-unknown" ];
    })
  ];

  buildInputs = [ nixpkgs.darwin.apple_sdk.frameworks.AppKit ];

  src = builtins.fetchGit {
    url = "https://github.com/holochain/holochain";
    rev = "a28eff8dbd688f59e2d16347185040336a0177f0";
  };

  cargoSha256 = "Q1CzDlyB6TeD8ixKnuKk9wfZ3YJM967lzIinqvPL8pE=";

  doCheck = false;
}
