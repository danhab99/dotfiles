import ../module.nix {
  name = "wayland";

  options =
    { lib }:
    with lib;
    {
      videoDrivers = mkOption {
        type = types.listOf types.str;
        default = [ "modesetting" ];
        description = "GPU kernel drivers to load (for DRM/KMS, not for X)";
      };
    };

  output =
    { pkgs, cfg, lib, ... }:
    {
      packages = with pkgs; [
        wev # wayland event viewer (replaces xev)
        wl-clipboard # wl-copy / wl-paste (replaces xclip/xsel)
        wlr-randr # wlroots output management (replaces xrandr)
        wdisplays # GUI output layout tool (replaces arandr)
        wayland-utils # wayland-info
        brightnessctl # backlight (replaces xbacklight)
        wtype # key/text injection (replaces xdotool)
      ];

      nixos = {
        # Enable DRM/KMS kernel drivers
        services.xserver.videoDrivers = cfg.videoDrivers;

        # Libinput for all input devices
        services.libinput.enable = true;

        # Basic Wayland session environment
        environment.sessionVariables = {
          XDG_SESSION_TYPE = "wayland";
          GDK_BACKEND = "wayland,x11";
          CLUTTER_BACKEND = "wayland";
        };

        # Enable XWayland for legacy X11 apps
        programs.xwayland.enable = true;
      };

      homeManager = { };
    };
}
