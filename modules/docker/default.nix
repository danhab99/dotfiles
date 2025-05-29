import ../module.nix {
  name = "docker";

  output = { pkgs, config, ... }: {
    packages = with pkgs; [
      dive
      lazydocker
      docker-compose
      docker-credential-helpers
      pass
    ];

    nixos = {
      hardware.nvidia-container-toolkit.enable = config.module.nvidia.enable;

      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;

        extraPackages = with pkgs; [
          docker-buildx
        ];

        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
  };
}
