# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.pipewire;

in {
  options.part.pipewire = { enable = mkEnableOption "pipewire"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      extraConfig.pipewire = {
        "99-disable-bell" = {
          "context.properties" = { "module.x11.bell" = false; };
        };
      };
    };
  };
}
