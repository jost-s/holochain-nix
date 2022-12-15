let
  pname = "holochain";
  version = "0.1.0-beta-rc.0";
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
    rev = "6adca3a4ab0121754be3af019c75a5222c17779a";
  };

  cargoSha256 = "I5q4w+33Hzk7ZqKtVGGvaiCyqM430fCiW8p409Hbmv4=";

  doCheck = false;
}
