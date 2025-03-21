import ../module.nix {
  name = "docker";

  output = { pkgs, ... }: {
    homeManager = { };

    nixos = {
      environment.systemPackages = with pkgs;
        [
          # ...
        ];

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
