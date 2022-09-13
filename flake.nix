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
    in
    {
      packages.aarch64-darwin = {

        holochain =
          with pkgs;
          let
            pname = "holochain";
            version = "0.0.156";
          in
          stdenv.mkDerivation
            {
              inherit pname version;

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
                  ref = "refs/tags/${pname}-${version}";
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

        lair =
          with pkgs;
          let
            pname = "lair-keystore";
            version = "v0.2.0";
          in
          stdenv.mkDerivation
            {
              inherit pname;
              inherit version;

              buildInputs = [
                (rust-bin.stable.latest.default.override {
                  extensions = [ "rust-src" ];
                  targets = [ "wasm32-unknown-unknown" ];
                })
                darwin.apple_sdk.frameworks.AppKit
                perl
              ];

              src = builtins.fetchGit
                {
                  url = https://github.com/holochain/lair.git;
                  ref = "refs/tags/lair_keystore-${version}";
                  rev = "20b18781d217f172187f16a0ef86b78eb1fcd3bd";
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
            };
      };
    };
}
