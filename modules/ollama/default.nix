import ../_module.nix {
  name = "ollama";

  options =
    { lib }:
      with lib;
      {
        repoDir = mkOption {
          type = types.str;
          description = "Directory for the ollama repository";
          # default = "/home/dan/.ollama";
          default = "/var/lib/ollama";
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

  output =
    { cfg
    , pkgs
    , lib
    , config 
    , ...
    }:
    {
      packages = with pkgs; [
        aichat
        argc
        # whisperx
        opencode
        crewai
      ];

      nixos = {
        module.nvidia.enable = lib.mkForce cfg.enableGpu;

        nixpkgs.config.permittedInsecurePackages = [ "python3.13-rapidocr-onnxruntime-1.4.4" ];

        nixpkgs.overlays = [
          (final: prev: {
            python3Packages = prev.python3Packages.overrideScope (
              pyFinal: pyPrev: {
                rapidocr-onnxruntime = pyPrev.rapidocr-onnxruntime.overrideAttrs (old: {
                  doCheck = false;
                  pytestCheckPhase = "echo 'skipping tests for rapidocr-onnxruntime'";
                });

                pyannote-audio = pyPrev.pyannote-audio.overridePythonAttrs (old: {
                  propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pyPrev.omegaconf ];
                });

              }
            );
          })
        ];

        services.open-webui = {
          enable = true;
          environment = {
            "OLLAMA_BASE_URL" = "http://localhost:11434";
          };
          host = "0.0.0.0";
          port = 20080;
        };

        module.nginx.virtualHosts."openwebui.localhost".port = 20080;
        module.nginx.virtualHosts."n8n.localhost".port = 5678;

        services.ollama = {
          enable = true;
          package = if cfg.enableGpu then pkgs.ollama-cuda else pkgs.ollama-cpu;

          loadModels = cfg.models;
          models = cfg.repoDir;

          host = "0.0.0.0";
          user = "ollama";

          environmentVariables = {
            OLLAMA_MODELS = cfg.repoDir;
            OLLAMA_HOST = "0.0.0.0";
            OLLAMA_CONTEXT_LENGTH = "65536";
          };
        };
      };
    };
}
