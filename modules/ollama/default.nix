# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "ollama";
  options = {
    repoDir = mkOption {
      type = lib.types.str;
      description = "Directory for the ollama repository";
    };
  };

  output = { ... }: {
    homeManager = {
      # home.packages = with pkgs; [ ollama ];

      services.ollama = {
        enable = true;
        # home = cfg.repoDir;
      };
    };
  }
}
