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

  output = { cfg, ... }: {
    nixos = {
      virtualisation.oci-containers.containers = {
        open-webui = {
          autoStart = true;
          image = "ghcr.io/open-webui/open-webui:main";
          environment = {
            # "OLLAMA_BASE_URL" = "http://host.docker.internal:11434";
            "OLLAMA_BASE_URL" = "http://localhost:11434";
            "WEBUI_SECRET_KEY" = "your_secret_key";
          };
          # ports = [ "127.0.0.1:20080:8080" ];
          extraOptions = [ "--network=host" ];
          volumes = [ "/home/dan/.open-webui/backend/data:/app/backend/data" ];
        };
      };

      services.ollama = {
        enable = true;
        acceleration = if cfg.enableGpu then "cuda" else false;

        loadModels = cfg.models;

        host = "0.0.0.0";

        environmentVariables = {
          OLLAMA_MODELS = cfg.repoDir;
          OLLAMA_HOST = "0.0.0.0";
        };
      };
    };
  };
}
