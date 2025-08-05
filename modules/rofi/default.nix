import ../module.nix {
  name = "rofi";

  options = { lib }: with lib; {
    theme = mkOption {
      name = "theme";
      default = "onedark";
    };
    font = mkOption {
      name = "font";
      default = "Fira Code 12";
    };
    icon_theme = mkOption {
      name = "icon";
      default = "Papirus";
    };
    modi = mkOption {
      name = "modi";
      default = "drun,run";
    };
    show_icons = mkOption {
      name = "show";
      default = true;
    };
    drun_display_format = mkOption {
      name = "drun";
      default = "{name}";
    };
  };

  output = { pkgs, lib, cfg, ... }: {
    packages = with pkgs; [ rofi ];

    homeManager.home.file = {
      ".config/rofi" =
        let
          rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
        in
        {
          source = pkgs.stdenv.mkDerivation {
            name = "adi1090x/rofi";
            version = rev;

            src = builtins.fetchGit {
              shallow = true;
              url = "https://github.com/danhab99/rofi.git";
              inherit rev;
            };

            installPhase = with cfg; ''
              echo PWD $(pwd)
              echo LS
              ls $src
              echo ---

              set -euo pipefail

              cd $(mktemp -d)

              # Set fake home directory
              export FAKEHOME="$(pwd)/fakehome"
              mkdir -p "$FAKEHOME"

              # Embed TOML config as a heredoc
              CONFIG_TOML="$FAKEHOME/rofi-config.toml"
              cat > "$CONFIG_TOML" <<EOF
              [setup]
              theme = "${theme}"
              font = "${font}"
              icon_theme = "${icon_theme}"
              modi = "${modi}"
              show_icons = ${show_icons}
              drun_display_format = "${drun_display_format}"
              EOF

              # Read values from embedded TOML config
              theme=$(grep '^theme' "$CONFIG_TOML" | cut -d'"' -f2)
              font=$(grep '^font' "$CONFIG_TOML" | cut -d'"' -f2)
              icon_theme=$(grep '^icon_theme' "$CONFIG_TOML" | cut -d'"' -f2)
              modi=$(grep '^modi' "$CONFIG_TOML" | cut -d'"' -f2)
              show_icons=$(grep '^show_icons' "$CONFIG_TOML" | cut -d'=' -f2 | xargs)
              drun_display_format=$(grep '^drun_display_format' "$CONFIG_TOML" | cut -d'"' -f2)

              # Clone the rofi themes repo if it doesn’t already exist
              ROFI_THEMES_DIR="$FAKEHOME/.local/share/rofi-themes"
              if [ ! -d "$ROFI_THEMES_DIR" ]; then
                mkdir -p "$ROFI_THEMES_DIR"
                git clone --depth=1 https://github.com/adi1090x/rofi.git "$ROFI_THEMES_DIR"
                bash "$ROFI_THEMES_DIR/setup.sh" --silent
              fi

              # Apply selected theme
              THEME_DIR="$ROFI_THEMES_DIR/themes"
              THEME_FILE="$THEME_DIR/$theme.rasi"
              if [ ! -f "$THEME_FILE" ]; then
                echo "Theme '$theme' not found in $THEME_DIR"
                exit 1
              fi

              mkdir -p "$FAKEHOME/.config/rofi"
              CONFIG_FILE="$FAKEHOME/.config/rofi/config.rasi"

              cat > "$CONFIG_FILE" <<EOF
              @theme "$theme"

              configuration {
                font: "$font";
                icon-theme: "$icon_theme";
                modi: "$modi";
                show-icons: $show_icons;
                drun-display-format: "$drun_display_format";
              }
              EOF

              echo "✅ Rofi configured with theme: $theme"
              echo "🎯 Config written to: $CONFIG_FILE"

              echo ---
              cp -r . $out
            '';
          };
          recursive = true;
        };
    };
  };
}
