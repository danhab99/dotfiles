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
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        enableNvidia = true;

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
