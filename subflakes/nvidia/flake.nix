{
  description = "nvidia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "nvidia";

    output = { pkgs, config, lib, ... }: {
      packages = with pkgs; [
        nvtopPackages.full
        cudaPackages.cudatoolkit
        cudaPackages.cuda_nvcc
        cudaPackages.cuda_cudart
        cudaPackages.libcublas
        cudaPackages.libcufft
        cudaPackages.libcurand
        cudaPackages.libcusparse
        cudaPackages.libcusolver
        cudaPackages.cudnn
      ];

      nixos = {
        nixpkgs.config = {
          cudaSupport = false;
          allowUnfree = true;
        };

        hardware.graphics = {
          enable = true;
        };

        hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          open = false;
          nvidiaSettings = true;

          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        environment.systemPackages = with pkgs; [
          cudaPackages.cudatoolkit
          cudaPackages.cuda_nvcc
          cudaPackages.cuda_cudart
        ];

        environment.variables = {
          VK_ICD_FILENAMES = "/run/opengl-driver/etc/vulkan/icd.d/nvidia_icd.json";
          VK_LAYER_PATH = "/run/opengl-driver/etc/vulkan/explicit_layer.d";
          __GL_THREADED_OPTIMIZATIONS = "1";
          __GL_SYNC_TO_VBLANK = "0";
          CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
          LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:${pkgs.cudaPackages.cuda_cudart}/lib";
        };
      };
    };
  };
}
