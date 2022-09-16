{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }:
    let
      system = "aarch64-darwin";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit overlays system; };
    in {
      packages.${system} = {

        holochain = with pkgs;
          let
            pname = "holochain";
            version = "0.0.161";
          in rustPlatform.buildRustPackage rec {
            inherit pname version;

            nativeBuildInputs = [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
            ];

            buildInputs = [ pkgs.darwin.apple_sdk.frameworks.AppKit ];

            src = builtins.fetchGit {
              url = "https://github.com/holochain/holochain";
              ref = "refs/tags/${pname}-${version}";
              rev = "cf8adc073596f4f5fc3dcf31c30bc8ade47a6f93";
            };

            cargoSha256 = "KaFScXhvo6/DHB9kjyOhK1dOd7btjuTSm3dNTgmH8dM=";

            doCheck = false;
          };

        lair = with pkgs;
          let
            pname = "lair-keystore";
            version = "v0.2.1";
          in rustPlatform.buildRustPackage rec {
            inherit pname;
            inherit version;

            nativeBuildInputs = [
              (rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" ];
                targets = [ "wasm32-unknown-unknown" ];
              })
              perl
            ];

            buildInputs = [ darwin.apple_sdk.frameworks.AppKit ];

            src = builtins.fetchGit {
              url = "https://github.com/holochain/lair.git";
              ref = "refs/tags/lair_keystore-${version}";
              rev = "840999730ff2a5bacea8a31ed8fbacc954291b5c";
            };

            cargoSha256 = "rSF0BQaGx18zvlGH3WlOUD7g9BQfden0ijsQEIMSWcg=";

            doCheck = false;
          };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          self.packages.${system}.holochain
          self.packages.${system}.lair
        ];
      };
    };
}
