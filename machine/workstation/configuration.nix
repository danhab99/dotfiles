import ../machine.nix
{
  hostName = "workstation";

  users = {
    dan.enable = true;
  };

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
      i3blocksConfig = ./i3blocks.conf;
      screen = [ "DP-5" "DP-1" "HDMI-0" ];
    };
    nix.enable = true;
    ollama = {
      enable = true;
      repoDir = "/ollama";
      models = [
        "bge-m3"
        "command-r-plus"
        "deepseek-r1"
        "gemma"
        "dolphin-mistral"
        "dolphin-mixtral"
        "mxbai-embed-large"
        "nomic-embed-text"
        "phi4"
        "qwq"
        "linux6200/bge-reranker-v2-m3"
        "wizardlm-uncensored"
        "deepseek-v3"
        "llama2-uncensored"
        "llama3.3:70b"
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
    neovim.enable = true;
    ranger.enable = true;
    rtlsdr.enable = true;
    nvidia.enable = true;
    obs.enable = true;
    vbox.enable = true;
    audio = {
      enable = true;
      enableJACK = true;
    };
    libreoffice.enable = true;
    gestures.enable = true;
    watchdog.enable = true;
  };

  files = {
    ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
    ".config/g600" = {
      source = ./g600;
      recursive = true;
    };
  };

  i3Config = { mod }: {
    keybindings = {
      "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && urxvt";
      # "${mod}+w" = "exec brave";
    };
  };

  xserver = ''
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

  bind =
    let
      bucket = dir: {
        inherit dir;
        dest = "bucket";
      };
    in
    [
      (bucket "Videos")
      (bucket "Music")
      (bucket "Pictures")
    ];

  jobs = { pkgs }: [
    {
      name = "backup";
      packages = pkgs: with pkgs; [ gnutar gzip findutils ];
      schedule = "*-*-* 04:00:00";

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
    }
    {
      script = "/home/dan/Music/download.sh";
      packages = with pkgs; [ gnutar gzip findutils ];
      name = "download-music";
      schedule = "*-*-* 02:00:00";
    }
  ];
}
