import ../_module.nix
{
  name = "firefox";
  requires = {
    nur.url = "github:nix-community/NUR";
  };

  output = { pkgs, nur, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.firefox = {
        enable = true;

        profiles.default = {
          id = 0;
          name = "Default";
          isDefault = true;

          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            vimium
            pushbullet
            bitwarden
          ];

          # 1. Declarative Settings
          settings = {
            "browser.search.region" = "US";
            "browser.search.isUS" = true;
            "distribution.searchplugins.defaultLocale" = "en-US";
            "general.useragent.locale" = "en-US";
            "browser.bookmarks.restore_default_bookmarks" = false;
            "extensions.activeAttributes" = true;

            # Keep top bar / bookmarks bar visible in fullscreen
            "browser.fullscreen.autohide" = false;

            # Set default zoom to 125%
            # Firefox uses a scale where 1.0 = 100%, so 1.25 = 125%
            "browser.zoom.siteSpecific" = true;
            "toolkit.zoomManager.zoomValues" = ".3,.5,.67,.8,.9,1,1.1,1.2,1.25,1.3,1.5"; # Adds 125 to the scale
            "layout.css.devPixelsPerPx" = "1.25"; # This zooms the UI and the content

            # Required for custom CSS to work
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };

          # 2. Custom CSS to remove the "weird border"
          # This targets the thin line often seen at the top of the tabs or sidebars
          userChrome = ''
            /* Remove the top line/border above the tabs */
            #nav-bar {
              border-top: 0 !important;
              box-shadow: none !important;
            }

            /* Remove potential app-wide container borders */
            #navigator-toolbox {
              border: none !important;
            }

            /* Ensure Bookmark bar stays visible in fullscreen if the setting alone isn't enough */
            #PersonalToolbar[inFullscreen="true"] {
              visibility: visible !important;
            }
          '';
        };
      };
    };

    nixos = { };
  };
}
