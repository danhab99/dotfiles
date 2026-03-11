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
        swayfx
        swaybg
        swayidle
        swaylock
        swww
        waypaper
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

          config = import ./config.nix { inherit mod fontSize lockCmd pkgs cfg lib; };

          extraConfig = ''
            # Workspace output assignments
            ${workspaceOutputAssigns}

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
          ];
          timeouts = [
            { timeout = 900; command = lockCmd; }
            {
              timeout = 1200;
              command = "${pkgs.swayfx}/bin/swaymsg 'output * dpms off'";
              resumeCommand = "${pkgs.swayfx}/bin/swaymsg 'output * dpms on'";
            }
          ];
        };

        stylix.targets = {
          sway.enable = true;
          swaylock.enable = true;
        };
      };
    };
}
