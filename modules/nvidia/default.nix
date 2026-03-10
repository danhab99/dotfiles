import ../module.nix {
  name = "nvidia";

  output =
    {
      pkgs,
      config,
      lib,
      ...
    }:
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
          extraPackages = with pkgs; [
            nvidia-vaapi-driver
            vulkan-validation-layers
          ];
        };

        hardware.nvidia = {
          modesetting.enable = true; # sets nvidia-drm.modeset=1 automatically
          powerManagement.enable = true;
          open = false; # use proprietary driver (not open kernel module)
          nvidiaSettings = true;

          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        # Load nvidia modules early so DRM is ready before the compositor starts
        boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

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
          # Wayland + NVIDIA: use GLES2 renderer — swayfx's fx_renderer is GLES2-based;
          # WLR_RENDERER=vulkan bypasses fx_renderer entirely (no corners/blur/shadows).
          WLR_RENDERER = "gles2";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          WLR_NO_HARDWARE_CURSORS = "1";
          # GBM_BACKEND nvidia-drm is NOT set — it causes crashes with newer drivers;
          # the Vulkan renderer path is the correct approach for wlroots + NVIDIA.
        };
      };
    };
}
