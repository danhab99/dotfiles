{
  description = "rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "rust";

    devshells =
      { pkgs, ... }:
      let
        rustToolchain = pkgs.rust-bin.beta.latest.default.override {
          extensions = [
            "rust-src"
            "rustfmt"
            "clippy"
          ];
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
  };
}
