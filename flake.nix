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
    in
    {
      packages.${system} = {

        holochain = with pkgs;
          let
            pname = "holochain";
            version = "0.0.145";
          in
          rustPlatform.buildRustPackage rec {
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
              rev = "f7ff004c0925cf19a52d90ff7f8df8ec6d8f170a";
            };

            cargoSha256 = "y6oXcqDMOUNmjBk+47e974WvWsPxychI7KZqgAH58Uc=";

            doCheck = false;
          };

        lair = with pkgs;
          let
            pname = "lair-keystore";
            version = "0.1.3";
          in
          rustPlatform.buildRustPackage rec {
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
              rev = "27e3a4e305e2a5d48ba625aa3bfac9516d2583ed";
            };

            cargoSha256 = "ITk3aQkvk2BYjBjFw8RnuLKIDSxeAtw/4ZFEAyzZKps=";

            doCheck = false;
          };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages =
          [ self.packages.${system}.holochain self.packages.${system}.lair ];
      };
    };
}
