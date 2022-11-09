let
  pname = "holochain";
  version = "signed-zome-calls-2";
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
    rev = "d2bfcc7d8345643184ea8dbbe2ee3028a448b93a";
    ref = "fix/signed-zome-call-resolve-conflicts";
  };

  cargoSha256 = "SRKvXdxZkgxYH2sbZNBbM+tf9jgEm0Xg/GZfGj7rPZ8=";

  doCheck = false;
}
