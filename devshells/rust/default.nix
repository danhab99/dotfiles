{ pkgs, ... }:
let
  rustToolchain = pkgs.rust-bin.beta.latest.default.override {
    extensions = [ "rust-src" "rustfmt" "clippy" ];
  };
in
{
  name = "rust";

  buildInputs = with pkgs; [
    rustup
    cargo
    pkg-config
    rustToolchain
    pkgs.rust-analyzer
    gdb
  ];

  RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";

  shellHook = ''
  '';
}
