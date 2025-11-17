import ../module.nix {
  name = "ollama";

  options = { lib }: with lib; {
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

  output = { cfg, pkgs, lib, ... }: {
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
          python3Packages = prev.python3Packages.overrideScope (pyFinal: pyPrev: {
            rapidocr-onnxruntime = pyPrev.rapidocr-onnxruntime.overrideAttrs (old: {
              doCheck = false;
              pytestCheckPhase = "echo 'skipping tests for rapidocr-onnxruntime'";
            });

            pyannote-audio = pyPrev.pyannote-audio.overridePythonAttrs (old: {
              propagatedBuildInputs =
                (old.propagatedBuildInputs or []) ++ [ pyPrev.omegaconf ];
            });

          });
        })
      ];

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

      # # Create the comfyui user and group
      # users.users.comfyui = {
      #   isSystemUser = true;
      #   home = "/var/lib/comfyui";
      #   createHome = true;
      #   group = "comfyui";
      #   shell = pkgs.bash;
      # };

      # users.groups.comfyui = { };

      # # Create the service
      # systemd.services.comfyui = {
      #   description = "ComfyUI Stable Diffusion Web Interface";
      #   after = [ "network.target" ];
      #   wantedBy = [ "multi-user.target" ];

      #   serviceConfig = {
      #     Type = "simple";
      #     User = "comfyui";
      #     Group = "comfyui";
      #     WorkingDirectory = "/var/lib/comfyui/ComfyUI";

      #     # Execute command
      #     ExecStart = "${pkgs.python3}/bin/python3 /var/lib/comfyui/ComfyUI/main.py --listen 0.0.0.0 --port 8188";

      #     # Restart settings
      #     Restart = "always";
      #     RestartSec = 10;

      #     # Security settings
      #     NoNewPrivileges = true;
      #     PrivateTmp = true;
      #     ProtectSystem = "strict";
      #     ProtectHome = true;

      #     # Logging
      #     StandardOutput = "journal";
      #     StandardError = "journal";
      #   };

      #   # Enable the service
      #   enable = true;
      # };

      # # Optional: Copy ComfyUI files to the user directory
      # environment.etc."comfyui.env".text = ''
      #   PYTHONPATH=/var/lib/comfyui/ComfyUI
      # '';
    };
  };
}
