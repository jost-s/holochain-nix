{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "aarch64-darwin";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs {
        inherit overlays system;
      };
      version = "0.0.156";
    in
    {
      defaultPackage.aarch64-darwin =
        with pkgs;
        stdenv.mkDerivation
          {
            pname = "holochain";
            inherit version;

            buildInputs = [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
              pkgs.darwin.apple_sdk.frameworks.AppKit
            ];

            src = builtins.fetchGit
              {
                url = https://github.com/holochain/holochain;
                ref = "refs/tags/holochain-${version}";
                rev = "46bff70ccb4a6f8fd06720d91774f0fdfc017d0b";
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
          };
    };
}
