# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.openssh;

in {
  options.modules.openssh = { enable = mkEnableOption "openssh"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openssl
    ];

    services.openssh = {
      enable = true;
      allowSFTP = true;
      authorizedKeysInHomedir = true;
      settings.PasswordAuthentication = false;
    };
  };
}
