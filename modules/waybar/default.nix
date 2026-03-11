import ../module.nix
{
  name = "waybar";

  output = { pkgs, lib, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "bottom";
            position = "bottom";
            height = 20;
            output = [
              "eDP-1"
              "HDMI-A-1"
              "DP-1"
              "DP-3"
            ];
            modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
            modules-center = [ ];
            modules-right = [
              "pulseaudio"
              "custom/gpu"
              "memory"
              "cpu"
              "disk#home"
              "disk#boot"
              "disk#bucket"
              "disk#data"
              "network"
              "temperature"
              "keyboard-state"
              "clock"
            ];

            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };

            "pulseaudio" = {
              format = "♪ {volume}%";
              format-muted = "♪ muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };

            "custom/gpu" = {
              exec = "nvidia-smi --query-gpu=utilization.gpu,utilization.memory,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | awk -F', ' '{print $1\"% mem:\" $2\"% \" $3\"°C\"}'";
              format = "GPU {}";
              interval = 1;
            };

            "memory" = {
              format = "MEM {percentage}%";
              interval = 10;
            };

            "cpu" = {
              format = "CPU {usage}%";
              interval = 1;
            };

            "disk#home" = {
              format = "HOME={used}/{total}({percentage_used}%)";
              path = "/home";
              interval = 30;
            };

            "disk#boot" = {
              format = "BOOT={used}/{total}({percentage_used}%)";
              path = "/";
              interval = 30;
            };

            "disk#bucket" = {
              format = "BUCKET={used}/{total}({percentage_used}%)";
              path = "/bucket";
              interval = 30;
            };

            "disk#data" = {
              format = "DATA={used}/{total}({percentage_used}%)";
              path = "/data";
              interval = 30;
            };

            "network" = {
              interface = "enp3s0";
              format-ethernet = "↑{bandwidthUpBytes} ↓{bandwidthDownBytes}";
              format-disconnected = "disconnected";
              interval = 1;
            };

            "temperature" = {
              format = "TEMP {temperatureC}°C";
              format-critical = "TEMP {temperatureC}°C";
              critical-threshold = 80;
              interval = 5;
            };

            "keyboard-state" = {
              capslock = true;
              numlock = true;
              format = "{name} {icon}";
              format-icons = {
                locked = "ON";
                unlocked = "off";
              };
            };

            "clock" = {
              format = "{:%a %m-%d-%y %H:%M:%S}";
              interval = 1;
            };
          };
        };

        style = lib.mkAfter ''
          * {
            font-size: 14px;
            font-weight: 600;
          }

          window#waybar {
            font-size: 14px;
            font-weight: 600;
            background-color: slategrey;
          }

          #pulseaudio,
          #cpu,
          #memory,
          #temperature,
          #clock,
          #network,
          #keyboard-state,
          #disk,
          #custom-gpu {
            padding-left: 10px;
            padding-right: 10px;
          }

          #pulseaudio { background-color: red; }
          #cpu { background-color: orange; }
          #memory { background-color: yellow; }
          #temperature { background-color: green; }
          #clock { background-color: blue; }
          #network { background-color: violet; }
          #keyboard-state { background-color: pink; }
          #disk { background-color: cyan; }
          #custom-gpu { background-color: grey; }

          #workspaces button {
            padding: 0 10px;
            font-weight: 600;
          }
        '';
      };

      stylix.targets = {
        waybar.enable = true;
      };
    };

    nixos = { };
  };
}
