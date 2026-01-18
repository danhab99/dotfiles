import ../module.nix {
  name = "docker";

  options =
    { lib }:
    with lib;
    {
      dataRoot = mkOption {
        type = types.str;
        default = "/var/lib/docker";
      };
    };

  output =
    {
      pkgs,
      config,
      cfg,
      ...
    }:
    {
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

          daemon.settings = {
            data-root = cfg.dataRoot;
          };

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
