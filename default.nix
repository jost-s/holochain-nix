let
  nixpkgs = import <nixpkgs> { };
  holochain = import ./holochain.nix;
  lair-keystore = import ./lair-keystore.nix;
in
nixpkgs.stdenv.mkDerivation {
  name = "holochain";
  buildInputs = [ holochain lair-keystore ];
  # outputs = [ holochain lair-keystore ];
}
