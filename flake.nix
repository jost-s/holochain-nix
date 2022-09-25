{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  nixConfig = {
    extra-substituters = [ "https://jost-s.cachix.org/" ];
    extra-trusted-public-keys =
      [ "jost-s.cachix.org-1:MJaFoUZA8dZ+v4zO8dLQd9D154zUWBwOUtEw0W26GL8=" ];
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
            version = "0.0.158";
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
              rev = "0cd777c789ee13ca655f9bffbd7fe11b49e47824";
            };

            cargoSha256 = "hAvMZccSgqjdGphPQ4CS4G12MduKclZPcG70RxBL6LU=";

            doCheck = false;
          };

        lair = with pkgs;
          let
            pname = "lair-keystore";
            version = "v0.2.0";
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
              rev = "20b18781d217f172187f16a0ef86b78eb1fcd3bd";
            };

            cargoSha256 = "rSF0BQaGx18zvlGHvWlOUD7g9BQfden0ijsQEIMSWcg=";

            doCheck = false;
          };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages =
          [ self.packages.${system}.holochain self.packages.${system}.lair ];
      };
    };
}
