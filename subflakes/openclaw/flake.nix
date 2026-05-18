{
  description = "openclaw NixOS module";

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
      name = "openclaw";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "openclaw module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            programs.openclaw = {
              enable = true;

              # stateDir = "/data/openclaw";
              documents = ./docs;
              config.gateway.mode = "local";
              config.models.providers.ollama = {
                baseUrl = "http://localhost:11434";
                api = "ollama";
                apiKey = "";
                models = [
                  {
                    id = "qwen3:latest";
                    name = "qwen3";
                  }
                  {
                    id = "deepseek-r1:14b";
                    name = "deekseek";
                  }
                  {
                    id = "gemma3:12b";
                    name = "gemma";
                  }
                ];
              };

              config.agents.defaults.model = "ollama/qwen3:latest";
            };
          };
        };
    };
}
