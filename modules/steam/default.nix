# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "steam";

  output = { ... }: {
    environment.systemPackages = with pkgs;
      [
        steam
      ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall =
        false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall =
        false; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall =
        false; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
