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
            version = "0.0.161";
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
                  rev = "cf8adc073596f4f5fc3dcf31c30bc8ade47a6f93";
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

      devShells.aarch64-darwin.default = 
      pkgs.mkShell {
        buildInputs = [
          self.packages.aarch64-darwin.holochain
          self.packages.aarch64-darwin.lair
        ];
      };
    };
}
