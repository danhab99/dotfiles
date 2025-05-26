import ../module.nix {
  name = "docker";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      dive
      lazydocker
      docker-compose
      docker-credential-helpers
      pass
    ];

    nixos = {
      hardware.nvidia-container-toolkit.enable = true;

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
