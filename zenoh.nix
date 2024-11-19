{ stdenv, fetchFromGitHub, rustPlatform, rustc, cargo, pkg-config, openssl, protobuf, zlib }:

rustPlatform.buildRustPackage rec {
  pname = "zenoh";
  version = "0.6.0";

  # src = fetchzip {
  #   url = "https://github.com/eclipse-zenoh/zenoh/archive/refs/tags/1.0.2.tar.gz";
  #   sha256 = "sha256-LCkdPv9w3715KF/p36KcyiQAKppyu+j+VROENpbFb80=";
  # };

  cargoSha256 = "sha256-YipQfzw3FmxjkXemuhdzICVFGn8GgwrPzd1G2Vcl0KA=";

  src = fetchFromGitHub {
    owner = "eclipse-zenoh";
    repo = "zenoh";
    rev = "1.0.2";
    sha256 = "sha256-LCkdPv9w3715KF/p36KcyiQAKppyu+j+VROENpbFb80=";
  };
  nativeBuildInputs = [ rustc cargo pkg-config ];
  buildInputs = [ openssl protobuf zlib ];

  buildPhase = ''
    cargo build --release 
  '';

  installPhase = ''
    install -D target/release/zenohd $out/bin/zenohd
    install -D target/release/zenoh-proto $out/bin/zenoh-proto
  '';
}
