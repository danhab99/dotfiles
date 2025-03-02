{ lib, config, ... }:

with lib;
let cfg = config.module.steam;

in {
  options.modules.steam = { enable = mkEnableOption "steam"; };

  config = mkIf cfg.enable {
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
