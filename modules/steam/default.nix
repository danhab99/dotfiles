import ../module.nix {
  name = "steam";

  output = { pkgs, ... }: {
    nixos = {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = false;
        localNetworkGameTransfers.openFirewall = false; 

        protontricks.enable = true;
      };

      hardware.steam-hardware.enable = true;
    };
  };
}
