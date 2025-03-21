import ../module.nix {
  name = "ollama";
  options = { lib }: with lib; {
    repoDir = mkOption {
      type = types.str;
      description = "Directory for the ollama repository";
    };
  };

  output = { ... }: {
    nixos = { };

    homeManager = {
      # home.packages = with pkgs; [ ollama ];

      services.ollama = {
        enable = true;
        # home = cfg.repoDir;
      };
    };
  };
}
