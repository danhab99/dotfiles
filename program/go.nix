{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
  ];

  # programs.go = {
  #   enable = true;
  #   goPath = "~/Documents/go";
  # };
}
