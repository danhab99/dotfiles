{
  description = "nightshift";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "nightshift";

    options = { lib, ... }: with lib; {
      scriptDirectory = mkOption { };
      time = mkOption { };
    };

    output = { pkgs, cfg, config, ... }:
      {
        nixos = {
          systemd.services.nightshift = {
            description = "Execute nightshift scripts";

            path = with pkgs; [ bash coreutils ] ++ config.environment.systemPackages;

            # The actual bash logic executed by the service
            script = ''
              # Get today's date in YYYY-MM-DD format (e.g., 2026-06-24)
              TODAY=$(${pkgs.coreutils}/bin/date +%Y-%m-%d)
              SCRIPT_PATH="${cfg.scriptDirectory}/$TODAY.sh"

              echo "Looking for today's script: $SCRIPT_PATH"

              if [ -f "$SCRIPT_PATH" ]; then
                echo "Script found. Executing..."
                # Running it explicitly with bash means the target script 
                # doesn't strictly need `chmod +x` or a shebang to work.
                ${pkgs.bash}/bin/bash "$SCRIPT_PATH"
              else
                echo "No script found for today ($TODAY). Exiting gracefully."
              fi
            '';

            serviceConfig = {
              Type = "oneshot";
              User = "dan";
              PAMName = "login";
            };
          };

          # 2. Define the Systemd Timer (Optional but recommended)
          systemd.timers.nightshift = {
            description = "Timer to trigger the nightshift";
            wantedBy = [ "timers.target" ];

            timerConfig = {
              OnCalendar = "*-*-* ${cfg.time}";
              Persistent = false;
            };
          };
        };
      };

  };
}
