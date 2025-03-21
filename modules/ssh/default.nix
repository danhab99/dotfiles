# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "ssh";

  output = { ... }: {
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
