import ../module.nix {
  name = "ollama";

  options = { lib }: with lib; {
    repoDir = mkOption {
      type = types.str;
      description = "Directory for the ollama repository";
      default = "/home/dan/.ollama";
    };
    models = mkOption {
      type = types.listOf types.str;
      description = "Default models to load";
      default = [ ];
    };
    enableGpu = mkOption {
      type = types.bool;
      default = false;
    };
  };

  output = { cfg, pkgs, ... }: {
    packages = with pkgs; [
      aichat
      openai-whisper
    ];

    nixos = {
      services.open-webui = {
        enable = true;
        environment = {
          "OLLAMA_BASE_URL" = "http://localhost:11434";
        };
        port = 20080;
      };

      services.ollama = {
        enable = true;
        acceleration = if cfg.enableGpu then "cuda" else false;

        loadModels = cfg.models;
        models = cfg.repoDir;

        host = "0.0.0.0";

        user = "ollama-user";

        environmentVariables = {
          OLLAMA_MODELS = cfg.repoDir;
          OLLAMA_HOST = "0.0.0.0";
        };
      };
    };
  };
}
