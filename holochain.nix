let
  pname = "holochain";
  version = "0.0.170";
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
    rev = "e9364427f6ebe1a7f3a8d75d252fd8445c039f2a";
  };

  cargoSha256 = "xgC3oAU9qKaTEEsl4a6m7CuFDFsdTutP3Ov6TkTSVEI=";

  doCheck = false;
}
