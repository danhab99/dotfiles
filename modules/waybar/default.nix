import ../module.nix
{
  name = "waybar";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "bottom";
            position = "bottom";
            height = 30;
            output = [
              "eDP-1"
              "HDMI-A-1"
              "DP-1"
              "DP-3"
            ];
            modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
            modules-center = [ ];
            modules-right = [ "pulseaudio" "cpu" "disk" "clock" "temperature" ];

            "sway/workspaces" = {
              disable-scroll = true;
              all-outputs = true;
            };
            "pulseaudio" = {
              format = " {volume}%";
              format-muted = "󰝟 muted";
              on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            };
            "cpu" = {
              format = " {usage}%";
              interval = 2;
            };
            "disk" = {
              format = "󰋊 {percentage_used}%";
              path = "/";
            };
            "clock" = {
              format = " {:%H:%M}";
              format-alt = " {:%Y-%m-%d %H:%M}";
              tooltip-format = "<tt>{calendar}</tt>";
            };
            "temperature" = {
              format = " {temperatureC}°C";
              format-critical = " {temperatureC}°C";
              critical-threshold = 80;
            };
          };
        };
      };

      stylix.targets = {
        waybar.enable = true;
      };
    };

    nixos = { };
  };
}
