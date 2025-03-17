# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.part.ssh;

in {
  options.part.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ openssh ];

    services.openssh = {
      enable = true;
      allowSFTP = true;
      authorizedKeysInHomedir = true;
      settings.PasswordAuthentication = false;
    };

    networking = {
      firewall = {
        allowedTCPPorts = [ 22 ];
        allowedUDPPorts = [ 22 ];
      };
    };
  };
}
