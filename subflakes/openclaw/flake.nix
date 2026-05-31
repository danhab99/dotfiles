{
  description = "openclaw";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    openclaw.url = "github:openclaw/nix-openclaw";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "openclaw";

    output = { pkgs, openclaw, ... }: {
      packages = with pkgs; [

      ];

      homeManager = {
        imports = [
          openclaw.homeManagerModules.openclaw
        ];

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
  };
}
