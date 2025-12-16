import ../module.nix
{
  name = "xdg";

  output = { pkgs, ... }: {
    packages = with pkgs; [

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

          defaultApplications = {
            # "text/plain" = [ "helix.desktop" ];           # Or "code.desktop"
            "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
            "image/png" = [ "org.gnome.eog.desktop" ];
            "application/pdf" = [ "brave-browser.desktop" ];
            "x-scheme-handler/http" = [ "brave-browser.desktop" ];
            "x-scheme-handler/https" = [ "brave-browser.desktop" ];
          };
        };
      };
    };

    nixos = {
      programs.dconf.enable = true;    # important for GSettings-based apps
      services.dbus.enable = true;     # usually already enabled, but ensure it is
    };
  };
}

