import ../devshell.nix
{
  name = "rust";

  versions = { pkgs, ... }:
    let
      rustToolchain = pkgs.rust-bin.beta.latest.default.override {
        extensions = [ "rust-src" "rustfmt" "clippy" ];
      };
    in
    {
      "d" = {
        packages = with pkgs; [
          rustup
          cargo
          pkg-config
          rustToolchain
          pkgs.rust-analyzer
          gdb
        ];

        env = {
          RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
        };
      };
    };

}
