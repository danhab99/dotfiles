import ../module.nix
{
  name = "nvidia";

  output = { pkgs, config, ... }: {
    packages = with pkgs; [
      nvtopPackages.full
    ];

    nixos = {
      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.production;
        open = false;
        forceFullCompositionPipeline = true;
        powerManagement.enable = true;
      };

      module = {
        xorg.videoDriver = "nvidia";
      };
    };
  };
}

