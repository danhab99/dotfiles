import ../module.nix 
{
  name = "nvidia";

  output = { pkgs, config, lib, ... }: {
    packages = with pkgs; [
      nvtopPackages.full
      cudatoolkit
    ];

    nixos = {
      nixpkgs.config = {
        cudaSupport = true;
        cudaVersion = "12";
      };

      hardware.graphics = {
        enable = true;
      };

      hardware.nvidia = {
        # For proprietary driver (best performance)
        modesetting.enable = true;
        powerManagement.enable = false;
        open = false; # Set to true for open kernel module (less tested)
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.variables = {
        # Force Vulkan to use NVIDIA driver
        VK_ICD_FILENAMES = "/run/opengl-driver/etc/vulkan/icd.d/nvidia_icd.json";
        VK_LAYER_PATH = "/run/opengl-driver/etc/vulkan/explicit_layer.d";
        # Optional performance tweaks
        __GL_THREADED_OPTIMIZATIONS = "1";
        __GL_SYNC_TO_VBLANK = "0";
        LD_LIBRARY_PATH = "${pkgs.cudatoolkit}/lib:${pkgs.cudnn}/lib";
      };

      module.xorg.videoDriver = lib.mkForce "nvidia";
    };
  };
}
