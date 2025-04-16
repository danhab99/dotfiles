import ../module.nix {
  name = "docker";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      dive
      lazydocker
    ];

    nixos = {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
      };
    };
  };
}
