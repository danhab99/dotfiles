import ../_module.nix
{
  name = "openclaw";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

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

      systemd.user.services.openclaw-gateway.Install.WantedBy = [ "default.target" ];
    };

    nixos = {
      module.nginx.virtualHosts."openclaw.localhost".port = 18789;
    };
  };
}
