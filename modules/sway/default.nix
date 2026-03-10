import ../module.nix {
  name = "sway";

  options =
    { lib }:
    with lib;
    {
      wallpaper = mkOption {
        type = types.nullOr types.path;
        description = "Path to wallpaper image";
        default = null;
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra sway config lines appended verbatim";
      };
      screen = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Ordered list of wlr output names for workspace assignment";
      };
      fontSize = mkOption {
        type = types.float;
        default = 12.0;
      };
      modKey = mkOption {
        type = types.str;
        default = "Mod4";
        description = "The modifier key (e.g. 'Mod4' or 'Mod1')";
      };
    };

  output =
    {
      pkgs,
      config,
      cfg,
      lib,
      ...
    }:
    let
      mod = cfg.modKey;
      fontSize = cfg.fontSize;

      swaybarConfig = pkgs.writeText "waybar-config.jsonc" (builtins.toJSON {
        layer = "top";
        position = "bottom";
        height = 30;
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "temperature" "battery" "clock" "tray" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
        };
        clock = {
          format = "{:%H:%M  %Y-%m-%d}";
        };
        cpu = {
          format = "CPU {usage}%";
        };
        memory = {
          format = "MEM {}%";
        };
        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "BAT {capacity}%";
          format-charging = "CHR {capacity}%";
          format-plugged = "PLG {capacity}%";
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          format-disconnected = "Disconnected";
        };
        pulseaudio = {
          format = "VOL {volume}%";
          format-muted = "MUTED";
          on-click = "pavucontrol";
        };
      });

      waybarStyle = pkgs.writeText "waybar-style.css" ''
        * {
          border: none;
          border-radius: 0;
          font-family: monospace;
          font-size: ${builtins.toString (builtins.floor fontSize)}px;
          min-height: 0;
        }
        window#waybar {
          background-color: rgba(47, 52, 63, 0.85);
          color: #f3f4f5;
        }
        #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: #676E7D;
          border-bottom: 3px solid transparent;
        }
        #workspaces button.focused {
          background: #2f343f;
          color: #f3f4f5;
          border-bottom: 3px solid #f3f4f5;
        }
        #workspaces button.urgent {
          background-color: #E53935;
        }
        #clock, #battery, #cpu, #memory, #temperature, #network, #pulseaudio, #tray {
          padding: 0 10px;
        }
      '';

      lockCmd = "${pkgs.swaylock}/bin/swaylock -f -c 2f343f";

      workspaceOutputAssigns =
        let
          screens = cfg.screen;
          nScreens = builtins.length screens;
        in
        if nScreens == 0 then ""
        else
          builtins.concatStringsSep "\n" (
            builtins.genList (
              i:
              let
                ws = builtins.toString (i + 1);
                screen = builtins.elemAt screens (lib.mod i nScreens);
              in
              "workspace ${ws} output ${screen}"
            ) 10
          );

      kanshiProfiles =
        if builtins.length cfg.screen == 0 then ""
        else
          let
            outputs = builtins.concatStringsSep "\n    " (
              builtins.map (s: "output ${s} enable mode 1920x1080 position 0,0") cfg.screen
            );
          in
          ''
            profile default {
              ${outputs}
            }
          '';

    in
    {
      packages = with pkgs; [
        brightnessctl
        foot
        grim
        kanshi
        mako
        nemo
        playerctl
        slurp
        sway
        swaybg
        swayidle
        swaylock
        waybar
        wdisplays
        wev
        wl-clipboard
        wlr-randr
        wtype
        xdg-utils
      ];

      nixos = {
        # Enable sway as a Wayland compositor
        programs.sway = {
          enable = true;
          wrapperFeatures.gtk = true;
          extraPackages = with pkgs; [
            swaylock
            swayidle
            foot
            waybar
            mako
            grim
            slurp
            wl-clipboard
            kanshi
            wdisplays
            wlr-randr
            brightnessctl
            wtype
          ];
        };

        # greetd as the display manager (lightweight, Wayland-native)
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
              user = "greeter";
            };
          };
        };

        # Ensure Wayland session env
        environment.sessionVariables = {
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "sway";
          MOZ_ENABLE_WAYLAND = "1";
          QT_QPA_PLATFORM = "wayland";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          SDL_VIDEODRIVER = "wayland";
          _JAVA_AWT_WM_NONREPARENTING = "1";
          NIXOS_OZONE_WL = "1";
          ELECTRON_OZONE_PLATFORM_HINT = "auto";
          WLR_NO_HARDWARE_CURSORS = "1";
          # Vulkan renderer — needed for NVIDIA proprietary + wlroots; harmless on others
          WLR_RENDERER = "vulkan";
        };

        # Security for swaylock PAM
        security.pam.services.swaylock = {
          enable = true;
          allowNullPassword = false;
        };

        # Disable X11 entirely
        services.xserver.enable = lib.mkForce false;
      };

      homeManager = {
        wayland.windowManager.sway = {
          enable = true;
          package = null; # use the system sway

          config = {
            modifier = mod;

            terminal = "foot";

            fonts = {
              names = [ "monospace" ];
              size = fontSize;
            };

            floating = {
              modifier = mod;
              criteria = [
                { app_id = "pavucontrol"; }
                { app_id = "wdisplays"; }
              ];
            };

            window = {
              titlebar = false;
              border = 0;
              commands = [
                {
                  command = "border pixel 0";
                  criteria = { app_id = ".*"; };
                }
                {
                  command = "border pixel 0";
                  criteria = { class = ".*"; };
                }
              ];
            };

            gaps = {
              inner = 20;
              outer = 12;
              smartBorders = "off";
            };

            colors = {
              focused = {
                border = "#2f343f";
                background = "#2f343f";
                text = "#f3f4f5";
                indicator = "#333333";
                childBorder = "#2f343f";
              };
              unfocused = {
                border = "#2f343f00";
                background = "#2f343f00";
                text = "#676E7D";
                indicator = "#333333";
                childBorder = "#2f343f00";
              };
              focusedInactive = {
                border = "#2f343f00";
                background = "#2f343f00";
                text = "#676E7D";
                indicator = "#333333";
                childBorder = "#2f343f00";
              };
              urgent = {
                border = "#E53935";
                background = "#E53935";
                text = "#f3f4f5";
                indicator = "#333333";
                childBorder = "#E53935";
              };
            };

            bars = [
              {
                command = "${pkgs.waybar}/bin/waybar";
              }
            ];

            keybindings = {
              "Pause" = "exec ${lockCmd}";
              "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
              "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
              "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
              "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
              "XF86AudioMicMute" = "exec ${pkgs.pamixer}/bin/pamixer --default-source -t";
              "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
              "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
              "${mod}+p" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
              "${mod}+w" = "exec brave";
              "${mod}+e" = "exec nemo";
              "${mod}+plus" = "gaps inner all minus 2";
              "${mod}+minus" = "gaps inner all plus 2";
              "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
              "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
              "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
              "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
              "${mod}+s" = "exec ${pkgs.wtype}/bin/wtype '¯\\_(ツ)_/¯'";
              "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
              "${mod}+c" = "exec ${pkgs.gnome-calculator}/bin/gnome-calculator";
              "${mod}+Shift+Ctrl+l" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'https://www.linkedin.com/in/danhabot/'";
              "${mod}+Ctrl+g" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'https://github.com/danhab99'";
              "${mod}+Ctrl+e" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'dan.habot@gmail.com'";
              "${mod}+Ctrl+a" = "exec ${pkgs.playerctl}/bin/playerctl previous";
              "${mod}+Ctrl+d" = "exec ${pkgs.playerctl}/bin/playerctl next";
              "${mod}+Ctrl+w" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
              "${mod}+Ctrl+s" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
              "${mod}+Return" = "exec foot";
              "${mod}+Ctrl+Return" = "exec rm -f /tmp/workdir && foot";
              "${mod}+q" = "kill";
              "${mod}+h" = "focus left";
              "${mod}+j" = "focus down";
              "${mod}+k" = "focus up";
              "${mod}+l" = "focus right";
              "${mod}+Left" = "focus left";
              "${mod}+Down" = "focus down";
              "${mod}+Up" = "focus up";
              "${mod}+Right" = "focus right";
              "${mod}+Shift+h" = "move left";
              "${mod}+Shift+j" = "move down";
              "${mod}+Shift+k" = "move up";
              "${mod}+Shift+l" = "move right";
              "${mod}+Shift+Left" = "move left";
              "${mod}+Shift+Down" = "move down";
              "${mod}+Shift+Up" = "move up";
              "${mod}+Shift+Right" = "move right";
              "${mod}+v" = "split toggle";
              "${mod}+f" = "fullscreen toggle";
              "${mod}+Shift+space" = "floating toggle";
              "${mod}+space" = "focus mode_toggle";
              "${mod}+a" = "focus parent";
              "${mod}+1" = "workspace number 1";
              "${mod}+2" = "workspace number 2";
              "${mod}+3" = "workspace number 3";
              "${mod}+4" = "workspace number 4";
              "${mod}+5" = "workspace number 5";
              "${mod}+6" = "workspace number 6";
              "${mod}+7" = "workspace number 7";
              "${mod}+8" = "workspace number 8";
              "${mod}+9" = "workspace number 9";
              "${mod}+0" = "workspace number 10";
              "${mod}+Shift+1" = "move container to workspace number 1";
              "${mod}+Shift+2" = "move container to workspace number 2";
              "${mod}+Shift+3" = "move container to workspace number 3";
              "${mod}+Shift+4" = "move container to workspace number 4";
              "${mod}+Shift+5" = "move container to workspace number 5";
              "${mod}+Shift+6" = "move container to workspace number 6";
              "${mod}+Shift+7" = "move container to workspace number 7";
              "${mod}+Shift+8" = "move container to workspace number 8";
              "${mod}+Shift+9" = "move container to workspace number 9";
              "${mod}+Shift+0" = "move container to workspace number 10";
              "${mod}+Shift+c" = "reload";
              "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
              "${mod}+r" = "mode resize";
              "${mod}+d" = "exec app-launcher";
              "${mod}+shift+x" = "exec ${lockCmd}";
            };

            modes = {
              resize = {
                "h" = "resize shrink width 5 px or 5 ppt";
                "j" = "resize grow height 5 px or 5 ppt";
                "k" = "resize shrink height 5 px or 5 ppt";
                "l" = "resize grow width 5 px or 5 ppt";
                "Left" = "resize shrink width 5 px or 5 ppt";
                "Down" = "resize grow height 5 px or 5 ppt";
                "Up" = "resize shrink height 5 px or 5 ppt";
                "Right" = "resize grow width 5 px or 5 ppt";
                "Return" = "mode default";
                "Escape" = "mode default";
                "${mod}+r" = "mode default";
              };
            };

            startup = [
              { command = "ssh-add ~/.ssh/id_rsa"; }
              { command = "${pkgs.mako}/bin/mako"; }
            ] ++ (lib.optional (cfg.wallpaper != null) {
              command = "${pkgs.swaybg}/bin/swaybg -i ${cfg.wallpaper} -m fill";
              always = true;
            });

            focus = {
              wrapping = "force";
              followMouse = true;
              mouseWarping = true;
            };

            input = {
              "type:keyboard" = {
                xkb_layout = "us";
                xkb_options = "caps:none";
              };
              "type:touchpad" = {
                tap = "enabled";
                natural_scroll = "enabled";
                dwt = "enabled";
              };
            };

            assigns = {
              "2" = [
                { class = "steam"; }
                { class = "steam_app_2073850"; }
                { class = "steam_app_275850"; }
                { class = "steam_app_276703"; }
                { class = "tf_linux64"; }
              ];
            };
          };

          extraConfig = ''
            # Workspace output assignments
            ${workspaceOutputAssigns}

            # Machine-specific extra config
            ${cfg.extraConfig}
          '';
        };

        # Waybar config
        home.file.".config/waybar/config.jsonc".source = swaybarConfig;
        home.file.".config/waybar/style.css".source = waybarStyle;

        # Kanshi for dynamic output management (auto-detect monitors)
        home.file.".config/kanshi/config".text = kanshiProfiles;

        # Mako notification daemon
        home.file.".config/mako/config".text = ''
          default-timeout=5000
          background-color=#2f343fdd
          text-color=#f3f4f5
          border-color=#2f343f
          border-radius=12
          font=monospace ${builtins.toString (builtins.floor fontSize)}
        '';

        # Foot terminal config
        home.file.".config/foot/foot.ini".text = ''
          [main]
          font=monospace:size=${builtins.toString (builtins.floor fontSize)}
          pad=8x8

          [colors]
          alpha=0.85
          background=2f343f
          foreground=f3f4f5

          [mouse]
          hide-when-typing=yes
        '';

        # Swayidle: lock on idle, dpms off after longer idle
        services.swayidle = {
          enable = true;
          events = [
            { event = "before-sleep"; command = lockCmd; }
            { event = "lock"; command = lockCmd; }
          ];
          timeouts = [
            { timeout = 900; command = lockCmd; }
            {
              timeout = 1200;
              command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
              resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
            }
          ];
        };
      };
    };
}
