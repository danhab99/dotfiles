import ../module.nix {
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
    , ...
    }:
    {
      packages = with pkgs; [
        aichat
        argc
        whisperx
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
          };
        };

        services.n8n = {
          enable = true;

          customNodes =
            let
              mkNode = { version, owner, repo, hash, npmDepsHash }: pkgs.buildNpmPackage (finalAttrs: {
                inherit version npmDepsHash;
                pname = "n8n-${owner}-${repo}";

                src = pkgs.fetchFromGitHub {
                  inherit repo owner hash;
                  tag = "${finalAttrs.version}";
                };

                # eslint-plugin-n8n-nodes-base has a preinstall hook that enforces
                # pnpm via `only-allow`, which fails in the Nix offline sandbox.
                # npmFlags applies --ignore-scripts to the npm ci step; the build
                # phase still runs via explicit `npm run build` so tsc is unaffected.
                npmFlags = [ "--ignore-scripts" ];
              });

              # mkNode = { version, owner, repo, hash, npmDepsHash }: pkgs.fetchFromGitHub {
              #   pname = "N8NCustomNode-${owner}-${repo}";
              #   inherit repo owner hash;
              #   tag = "${version}";
              # };
            in
            [
              (mkNode {
                owner = "scraperapi";
                repo = "n8n-nodes-scraperapi-official";
                version = "1.1.0";
                hash = "sha256-wr9bJHodsxPeBtRZdZ34077lSdt4zQhobKbDfR2za/M=";
                npmDepsHash = "sha256-6yE8WU1ShZnI3tc+FIJ9MBa6R4mWXjGVyKNvYUTVBsw=";
              })
            ];
        };
      };
    };
}
