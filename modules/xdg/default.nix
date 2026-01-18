import ../module.nix {
  name = "xdg";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        xdg-utils
        xdg-user-dirs
        xdg-user-dirs-gtk
        desktop-file-utils
      ];

      homeManager = {
        # Enable XDG integration and default MIME apps

        xdg = {
          enable = true;
          # Enable XDG integration and default MIME apps
          configFile."mimeapps.list".force = true;

          # Default applications for MIME types
          mimeApps = {
            enable = true;

            defaultApplications =
              let
                default_browser = "brave-browser.desktop";
              in
              {
                "application/pdf" = [ default_browser ];
                "image/png" = [ "org.gnome.eog.desktop" ];
                "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
                "text/html" = default_browser;
                "x-scheme-handler/about" = default_browser;
                "x-scheme-handler/http" = default_browser;
                "x-scheme-handler/https" = default_browser;
                "x-scheme-handler/unknown" = default_browser;
              };
          };
        };
      };

      nixos = {
        programs.chromium.enable = true;
        programs.dconf.enable = true; # important for GSettings-based apps
        services.dbus.enable = true; # usually already enabled, but ensure it is

        xdg.portal = {
          enable = true;

          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
          ];

          config.common.default = "*";
        };
      };
    };
}
