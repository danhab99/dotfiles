import ../module.nix
{
  name = "rofi";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.rofi-adi1090x = {
        enable = true;

        # ── color scheme ────────────────────────────────────────────────────────
        # One of: adapta arc black catppuccin cyberpunk dracula everforest
        #         gruvbox lovelace navy nord onedark paper solarized tokyonight yousai
        colorScheme = "onedark";

        # ── launcher ────────────────────────────────────────────────────────────
        launcher = {
          commandName = "app-launcher"; # command added to PATH
          type = 7; # layout family 1–7
          style = 2; # style variant  1–15
          show = "drun"; # rofi -show mode: drun | run | window | filebrowser
        };

        # ── power menu ──────────────────────────────────────────────────────────
        powermenu = {
          commandName = "power-menu"; # command added to PATH
          type = 2; # layout family 1–6
          style = 3; # style variant  1–5
          # set any action to null to remove it from the menu
          lock = "swaylock -f -c 2f343f";
          suspend = "systemctl suspend";
          hibernate = null; # hidden — not shown in the menu
          logout = "loginctl kill-session \"$XDG_SESSION_ID\"";
          reboot = "systemctl reboot";
          shutdown = "systemctl poweroff";
        };

        # ── applets ─────────────────────────────────────────────────────────────
        applets = {
          type = 2; # layout family 1–5
          style = 1; # style variant  1–3

          # commands launched by the Apps applet
          apps = {
            terminal = "kitty";
            fileManager = "nautilus";
            textEditor = "code";
            browser = "firefox";
            music = "spotify";
            settings = "gnome-control-center";
          };

          # entries shown in the Quick Links applet (max 6)
          quickLinks = [
            { name = "GitHub"; url = "https://github.com/"; icon = ""; }
            { name = "YouTube"; url = "https://www.youtube.com/"; icon = ""; }
            { name = "NixOS"; url = "https://nixos.org/"; icon = ""; }
            { name = "Hacker News"; url = "https://news.ycombinator.com/"; icon = ""; }
          ];
        };

        # ── rofi global config ──────────────────────────────────────────────────
        rofiConfig = {
          modi = "drun,run,window,filebrowser";
          font = "JetBrains Mono Nerd Font 12";
          iconTheme = "Papirus";
          showIcons = true;
          terminal = "kitty";
          # verbatim lines injected into configuration { } in config.rasi
          extraConfig = ''
            display-drun: "Apps";
            drun-display-format: "{name}";
            disable-history: false;
          '';
        };

        # ── fonts & dependencies ────────────────────────────────────────────────
        installFonts = true; # install bundled Nerd Fonts (default: true)
        withOptionalDeps = true; # install acpi, light, mpd, maim, xclip, etc.
        extraPackages = [ pkgs.alacritty ];
      };
    };
  };
}
