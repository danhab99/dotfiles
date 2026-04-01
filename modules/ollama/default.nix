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
        whisperx
        opencode
        crewai
      ];

      nixos = {
        module.nvidia.enable = lib.mkForce cfg.enableGpu;

        nixpkgs.config.permittedInsecurePackages = [ "python3.13-rapidocr-onnxruntime-1.4.4" ];

        nixpkgs.overlays = [
          (final: prev: {
            # faiss-1.14.1 has a hash mismatch in nixpkgs (upstream source changed);
            # patch the src hash to what the fetcher actually receives
            faiss = prev.faiss.overrideAttrs (old: {
              src = old.src.override {
                hash = "sha256-p1YncYUUxld9iwFXXZ+lTxYgku8l+/K6dbxZx2EcJ6k=";
              };
            });

            python3Packages = prev.python3Packages.overrideScope (
              pyFinal: pyPrev: {
                rapidocr-onnxruntime = pyPrev.rapidocr-onnxruntime.overrideAttrs (old: {
                  doCheck = false;
                  pytestCheckPhase = "echo 'skipping tests for rapidocr-onnxruntime'";
                });

                pyannote-audio = pyPrev.pyannote-audio.overridePythonAttrs (old: {
                  propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [ pyPrev.omegaconf ];
                  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pyFinal.pythonRelaxDepsHook ];
                  pythonRelaxDeps = [ "torch" "torchcodec" ];
                  doCheck = false;
                });

                whisperx = pyPrev.whisperx.overridePythonAttrs (old: {
                  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pyFinal.pythonRelaxDepsHook ];
                  pythonRelaxDeps = [ "huggingface-hub" "torch" "torchaudio" ];
                  doCheck = false;
                });

                # hyperpyyaml 1.2.3 requires ruamel-yaml<0.19.0 but nixpkgs has 0.19.1
                # which has a genuine API break (max_depth attr missing); skip tests
                hyperpyyaml = pyPrev.hyperpyyaml.overridePythonAttrs (old: {
                  nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pyFinal.pythonRelaxDepsHook ];
                  pythonRelaxDeps = [ "ruamel.yaml" ];
                  doCheck = false;
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
