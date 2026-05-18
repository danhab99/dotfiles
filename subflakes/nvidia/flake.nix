{
  description = "nvidia NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "nvidia";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "nvidia module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
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
              cudaSupport = false; # Disable global CUDA support to avoid build issues
              allowUnfree = true;
            };

            hardware.graphics = {
              enable = true;
            };

            hardware.nvidia = {
              modesetting.enable = true;
              powerManagement.enable = true;
              open = false; # use proprietary driver (not open kernel module)
              nvidiaSettings = true;

              package = config.boot.kernelPackages.nvidiaPackages.stable;
            };

            environment.systemPackages = with pkgs; [
              # Add CUDA packages to system for apps that need them
              cudaPackages.cudatoolkit
              cudaPackages.cuda_nvcc
              cudaPackages.cuda_cudart
            ];

            environment.variables = {
              # Force Vulkan to use NVIDIA driver
              VK_ICD_FILENAMES = "/run/opengl-driver/etc/vulkan/icd.d/nvidia_icd.json";
              VK_LAYER_PATH = "/run/opengl-driver/etc/vulkan/explicit_layer.d";
              # Optional performance tweaks
              __GL_THREADED_OPTIMIZATIONS = "1";
              __GL_SYNC_TO_VBLANK = "0";
              # CUDA library paths
              CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
              LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:${pkgs.cudaPackages.cuda_cudart}/lib";
            };
          };
        };
    };
}
