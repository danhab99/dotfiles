# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.nix;

in {
  options.part.nix = { enable = mkEnableOption "nix"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        nix-index
      ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    nixpkgs.config.allowBroken = true;

    # services.nixos-cli = { enable = true; };

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [ gtk3 glibc swt freetype ];

    environment.variables = with pkgs; {
      LD_LIBRARY_PATH = "${swt}/lib:$LD_LIBRARY_PATH";
    };
  };
}
