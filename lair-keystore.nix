with import <nixpkgs> { };

let
  pname = "lair-keystore";
  version = "v0.2.1";
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
      rev = "840999730ff2a5bacea8a31ed8fbacc954291b5c";
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
}
