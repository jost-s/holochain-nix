let
  pkgs = import <nixpkgs> { };
  holochain = import ./holochain.nix;
  lair-keystore = import ./lair-keystore.nix;
in pkgs.mkShell { packages = [ holochain lair-keystore ]; }
