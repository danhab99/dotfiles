{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nil nixfmt-classic nixpkgs-lint ];
}
