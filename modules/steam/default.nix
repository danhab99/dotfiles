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

        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [
            # libvulkan
            vulkan-loader
            vulkan-validation-layers
            mesa
          ];
        };
      };

      hardware.steam-hardware.enable = true;
    };
  };
}
