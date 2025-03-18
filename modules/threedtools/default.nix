# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.threedtools;

in {
  options.modules.threedtools = { enable = mkEnableOption "threedtools"; };
  config = mkIf cfg.enable { 
    home.packages = with pkgs; [ 
      freecad
      blender
      bambu-studio
    ];

    home.file = [ 
      # ...
    ];

    # ...
  };
}
