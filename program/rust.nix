{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rustc
    rustfmt
    rustup
    cargo
  ];
}
