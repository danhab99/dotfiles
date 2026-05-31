{
  description = "xdg";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
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
          xdg = {
            enable = true;
            configFile."mimeapps.list".force = true;

            mimeApps = {
              enable = true;

              defaultApplications =
                let
                  default_browser = "firefox.desktop";
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
          programs.dconf.enable = true;
          services.dbus.enable = true;

          xdg.portal = {
            enable = true;

            extraPortals = with pkgs; [
              xdg-desktop-portal-gtk
            ];

            config.common.default = "*";
          };
        };
      };
  };
}
