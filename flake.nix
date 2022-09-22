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
            version = "0.0.163";
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
              rev = "0cd777c789ee13ca655f9bffbd7fe11b49e47824";
            };

            cargoSha256 = "e+xwvJeAN2Z3peNLcCiVPQHY8/SmPdYAABK2+j7uJs8=";

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

            cargoSha256 = "zCrBBaqgVE5EWfKkkKEqy8lHx9ZTxpOvSb0b19Bh0z8=";

            doCheck = false;
          };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages =
          [ self.packages.${system}.holochain self.packages.${system}.lair ];
      };
    };
}
