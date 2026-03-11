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
        slowMode = mkOption {
          type = types.bool;
          default = false;
          description = "Reduce waybar update frequency for slow displays (e.g. DisplayLink)";
        };
        defaultLayoutScript = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Path to a script run on sway startup to configure display layout (e.g. a wlr-randr script)";
        };
      };

  output =
    { pkgs
    , config
    , cfg
    , lib
    , ...
    }:
    let
      mod = cfg.modKey;
      fontSize = cfg.fontSize;

      lockCmd = "${pkgs.swaylock}/bin/swaylock -f -c 2f343f";

      workspaceOutputAssigns =
        let
          screens = cfg.screen;
          nScreens = builtins.length screens;
        in
        if nScreens == 0 then ""
        else
          builtins.concatStringsSep "\n" (
            builtins.genList
              (
                i:
                let
                  ws = builtins.toString (i + 1);
                  screen = builtins.elemAt screens (lib.mod i nScreens);
                in
                "workspace ${ws} output ${screen}"
              ) 10
          );

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
        swayfx
        swaybg
        swayidle
        swaylock
        swww
        waypaper
        waybar
        wdisplays
        wev
        wl-clipboard
        wlr-randr
        wtype
        xdg-utils
      ];

      nixos = {
        # Enable swayfx as the Wayland compositor (sway fork with rounded corners + blur)
        programs.sway = {
          enable = true;
          package = pkgs.swayfx;
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
            swww
            waypaper
          ];
        };

        # greetd as the display manager (lightweight, Wayland-native)
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'sway --unsupported-gpu'";
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
          systemdIntegration = true; # activates sway-session.target so kanshi + other services start

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
              "${mod}+Shift+r" = "reload";
              "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
              "${mod}+r" = "mode resize";
              "${mod}+d" = "exec app-launcher";
              "${mod}+Shift+w" = "exec waypaper";
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
              { command = "${pkgs.swww}/bin/swww-daemon"; }
            ] ++ (lib.optional (cfg.defaultLayoutScript != null) {
              command = builtins.toString cfg.defaultLayoutScript;
              always = true;
            }) ++ (lib.optional (cfg.wallpaper != null) {
              command = "${pkgs.swww}/bin/swww img ${cfg.wallpaper}";
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

            # Fallback: enable any hot-plugged output with a sensible default.
            # Without this sway silently ignores newly connected screens (e.g. KVM switch).
            output * enable

            # Rounded corners + blur (swayfx)
            corner_radius 16
            blur enable
            blur_passes 3
            blur_radius 5

            # Drop shadow on focused window only (picom-style)
            shadows enable
            shadow_blur_radius 20
            shadow_color #000000AA
            shadow_offset 0 4
            shadow_inactive_color #00000000

            # Machine-specific extra config
            ${cfg.extraConfig}
          '';
        };

        # Waybar config

        # Kanshi for dynamic output management (auto-detect monitors)
        # Run as a systemd user service so it responds to output hotplug events
        services.kanshi = {
          enable = true;
          systemdTarget = "sway-session.target";
          settings = lib.optionals (builtins.length cfg.screen > 0) [
            {
              profile.name = "default";
              profile.outputs = builtins.map (s: {
                criteria = s;
                status = "enable";
                mode = "1920x1080";
              }) cfg.screen;
            }
          ];
        };

        # Mako notification daemon
        home.file.".config/mako/config".text = ''
          default-timeout=5000
          background-color=#2f343fdd
          text-color=#f3f4f5
          border-color=#2f343f
          border-radius=12
          font=monospace ${builtins.toString (builtins.floor fontSize)}
        '';

        # Foot terminal config (use programs.foot so stylix can merge colours)
        programs.foot = {
          enable = true;
          settings = {
            main = {
              font = "monospace:size=${builtins.toString (builtins.floor fontSize)}";
              pad = "16x16";
            };
            colors = {
              alpha = "0.85";
            };
          };
        };

        # Waypaper config — point it at swww as the backend
        home.file.".config/waypaper/config.ini".text = ''
          [Settings]
          folder = ~/Pictures/wallpaper/3screen
          backend = swww
          fill = fill
          sort = name
          subfolders = True
        '';

        # Swayidle: lock on idle, dpms off after longer idle
        services.swayidle = {
          enable = true;
          events = [
            { event = "before-sleep"; command = lockCmd; }
            { event = "lock"; command = lockCmd; }
            # Re-enable all outputs when any output is (re-)connected, e.g. KVM switch
            { event = "after-resume"; command = "${pkgs.swayfx}/bin/swaymsg 'output * enable'"; }
          ];
          timeouts = [
            { timeout = 900; command = lockCmd; }
            {
              timeout = 1200;
              command = "${pkgs.swayfx}/bin/swaymsg 'output * dpms off'";
              resumeCommand = "${pkgs.swayfx}/bin/swaymsg 'output * dpms on && output * enable'";
            }
          ];
        };

        stylix.targets = {
          foot.enable = true;
          sway.enable = true;
          swaylock.enable = true;
          waybar.enable = true;
        };

      };
    };
}
