with import <nixpkgs> { };

let
  pname = "holochain";
  version = "0.0.145";
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
      rev = "f7ff004c0925cf19a52d90ff7f8df8ec6d8f170a";
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
}


# { lib, fetchFromGitHub, rustPlatform }:

# rustPlatform.buildRustPackage rec {
#   pname = "ripgrep";
#   version = "12.1.1";

#   src = fetchFromGitHub {
#     owner = "BurntSushi";
#     repo = pname;
#     rev = version;
#     sha256 = "1hqps7l5qrjh9f914r5i6kmcz6f1yb951nv4lby0cjnp5l253kps";
#   };

#   cargoSha256 = "03wf9r2csi6jpa7v5sw5lpxkrk4wfzwmzx7k3991q3bdjzcwnnwp";

#   meta = with lib; {
#     description = "A fast line-oriented regex search tool, similar to ag and ack";
#     homepage = "https://github.com/BurntSushi/ripgrep";
#     license = licenses.unlicense;
#     maintainers = [ maintainers.tailhook ];
#   };
# }
