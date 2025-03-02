# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.rofi;

in {
  options.modules.rofi = { enable = mkEnableOption "rofi"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ rofi ];

    home.file = {
      ".config/rofi" = {
        source = builtins.fetchGit {
          shallow = true;
          url = "https://github.com/adi1090x/rofi.git";
          rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
        };
        recursive = true;
      };
    };
  };
}
