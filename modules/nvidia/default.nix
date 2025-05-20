import ../module.nix 
{
  name = "nvidia";

  output = { pkgs, config, lib, ... }: {
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

      hardware.graphics = {
        enable = true;
        enable32Bit = true; # for 32-bit applications
      };

      module = {
        xorg.videoDriver = lib.mkForce "nvidia";
      };
    };
  };
}
