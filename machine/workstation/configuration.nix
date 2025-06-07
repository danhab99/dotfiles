{ pkgs, ... }:

{
  imports = [
    ../../modules
    ../../users
  ];

  config.users = {
    dan.enable = true;
  };

  config = {
    module = {
      appimage.enable = true;
      docker.enable = true;
      font.enable = true;
      fzf.enable = true;
      git = {
        enable = true;
        signingKey = "1DC36AE6EEEFDB55FE5D8874BAABD1E3FA0A9FB6";
        email = "dan.habot@gmail.com";
      };
      gnupg.enable = true;
      i18n.enable = true;
      i3 = {
        enable = true;
        configFile = ./i3/config;
        # i3BlocksConfig = ./i3blocks.conf;
        screen = [ "DP-5" "DP-1" "HDMI-0" ];
      };
      nix.enable = true;
      ollama = {
        enable = true;
        repoDir = "/bucket/ollama";
        models = [
          "bge-m3"
          "command-r-plus"
          "deepseek-r1"
          "gemma"
          "llama3.3"
          "mistral"
          "mixtral"
          "mxbai-embed-large"
          "nomic-embed-text"
          "phi4"
          "qwq"
          "linux6200/bge-reranker-v2-m3"
        ];
        enableGpu = true;
      };
      # pipewire.enable = true;
      printing.enable = true;
      ratbag.enable = true;
      rofi.enable = true;
      sddm.enable = true;
      secrets.enable = true;
      ssh.enable = true;
      steam.enable = true;
      threedtools.enable = true;
      timezone.enable = true;
      urxvt.enable = true;
      xorg =
        {
          enable = true;
          videoDriver = "nvidia";
          extraConfig = ''
            urxvt*depth: 32
            urxvt*blurRadius: 10
            urxvt*transparent: true
            urxvt*tintColor: #525252
          '';
        };
      zoxide.enable = true;
      zsh.enable = true;
      vim.enable = true;
      ranger.enable = true;
      rtlsdr.enable = true;
      nvidia.enable = true;
      obs.enable = true;
      vbox.enable = true;
      wireguard.enable = true;
      audio = {
        enable = true;
        enableJACK = true;
      };
    };

    environment.systemPackages = with pkgs; [
      libratbag
    ];

    environment.variables = {
      "__EGL_VENDOR_LIBRARY_FILENAMES" = "/usr/share/glvnd/egl_vendor.d/50_mesa.json";
      "WEBKIT_DISABLE_DMABUF_RENDERER" = 1;
      "WEBKIT_FORCE_COMPOSITING_MODE" = 1;
      "WEBKIT_DISABLE_COMPOSITING_MODE" = 1;
    };

    home-manager.users.dan = {
      home.file = {
        ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
        ".config/g600" = {
          source = ./g600;
          recursive = true;
        };
      };

      xsession.windowManager.i3.config =
        let
          mod = "Mod4";
        in
        {
          keybindings = {
            "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && urxvt";
            # "${mod}+w" = "exec brave";
          };

        };
    };

    services.xserver.config = ''
      Section "Device"
      Identifier "GPU0"
      Driver "nvidia"
      Option "AllowFlipping" "True"
      Option "TripleBuffer" "True"
      Option "ForceFullCompositionPipeline" "True"
      EndSection

        Section "Monitor"
            Identifier "HDMI-0"
            Option "PreferredMode" "1920x1080"
        EndSection

        Section "Monitor"
            Identifier "DP-5"
            Option "PreferredMode" "1920x1080"
            Option "RightOf" "HDMI-0"
        EndSection

        Section "Monitor"
            Identifier "DP-1"
            Option "PreferredMode" "1920x1080"
            Option "RightOf" "DP-5"
        EndSection

        Section "Screen"
            Identifier "Screen0"
            Device "GPU0"
            Option "metamodes" "HDMI-0: 1920x1080 +0+0, DP-5: 1920x1080 +1920+0, DP-1: 1920x1080 +3840+0"
            Option "AllowIndirectGLXProtocol" "True"
            Option "TripleBuffer" "True"
        EndSection
    '';

    systemd = {
      tmpfiles.rules =
        let
          bind = dir: "L+ /home/dan/${dir} - - - - /bucket/${dir}";
        in
        [
          (bind "Videos")
          (bind "Pictures")
          (bind "Music")
        ];

      services."backup" = {
        script = ''
          set -eu

          function cleanup_old_backups() {
            ${pkgs.findutils}/bin/find /bucket/backup -type f -name "*.tar.gz" -mtime +7 -delete
          }

          function backup() {
            ${pkgs.gnutar}/bin/tar -cz \
            --exclude-caches \
            --exclude="**/node_modules" \
            --exclude="**/*[Cc]ache*" \
            --exclude="/home/dan/Videos" \
            --exclude="/home/dan/Pictures" \
            --seek \
            -f /bucket/backup/$1.$(date +%Y-%m-%d).tar.gz $2
          }

          cleanup_old_backups
          backup home /home/dan &

          wait
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        path = with pkgs; [ gnutar gzip findutils ];
      };

      timers."backup" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = true;
        };
      };

      services."download-music" = {
        script = "/home/dan/Music/download.sh";

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        path = with pkgs; [ gnutar gzip findutils ];
      };

      timers."download-music" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00";
          Persistent = true;
        };
      };
    };
  };
}
