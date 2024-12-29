{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gcc
    gcc10
    gcc11
    gcc12
    gcc13
    gcc14
    clang-tools
  ];
}
