import ../machine.nix
{
  hostName = "workstation";
  system = "x86_64-linux";

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
      screen = [ "DP-4" "DP-0" "HDMI-0" ];
      defaultLayoutScript = "3screen.sh";
      fontSize = 14.0;
    };
    nix.enable = true;
    ollama = {
      enable = true;
      repoDir = "/data/ollama";
      models = [
        "bge-large:latest"
        "codegemma:2b-code-v1.1-fp16"
        "codegemma:7b-code-q6_K"
        "codegemma:7b-instruct"
        "codellama:7b-code-q8_0"
        "codellama:7b-instruct-q8_0"
        "codellama:7b-python-q8_0"
        "codeqwen:7b-code-v1.5-q8_0"
        "codestral:22b-v0.1-q3_K_L"
        "command-r7b:7b-12-2024-q8_0"
        "deepseek-r1:14b"
        "embeddinggemma"
        "gemma3:12b"
        "gemma3:12b-it-qat"
        "llama3.1:8b"
        "llama3.1:8b-instruct-q8_0"
        "llama3.2:3b-instruct-fp16"
        "mistral:7b-instruct-v0.3-q8_0"
        "mistral:text"
        "nomic-embed-text"
        "qwen3:4b-instruct-2507-fp16"
        "qwen3:4b-thinking-2507-fp16"
      ];
      enableGpu = true;
    };
    printing.enable = true;
    ratbag.enable = true;
    rofi.enable = true;
    sddm.enable = true;
    secrets.enable = true;
    ssh = {
      enable = true;
      enableFail2Ban = true;
    };
    steam.enable = true;
    threedtools.enable = true;
    timezone.enable = true;
    urxvt.enable = true;
    xorg =
      {
        enable = true;
        videoDrivers = [ "nvidia" ];
        # defaultScreenScript = "3screen.sh";
        extraConfig = ''
          urxvt*depth: 32
          urxvt*blurRadius: 10
          urxvt*transparent: true
          urxvt*tintColor: #525252
        '';
        fontSize = 21;
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
    };
    libreoffice.enable = true;
    gestures = {
      enable = true;
      devicePath = "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:4.4.3:1.0-event-mouse";
    };
    watchdog.enable = true;
    vscode.enable = true;
    qmk.enable = true;
    tmux.enable = true;
    cli-notes = {
      enable = true;
      source-path = "~/Documents/bash/notes";
    };
    xdg.enable = true;
    redshift.enable = true;
    wireguard.enable = true;

    all-packages.enable = true;
    nixos-packages.enable = true;
  };

  nixos = {
    # Enable binfmt emulation for building ARM images
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
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
        Option "PreferredMode" "2560x1440"
    EndSection

    Section "Monitor"
        Identifier "DP-0"
        Option "PreferredMode" "2560x1440"
        Option "LeftOf" "HDMI-0"
    EndSection

    Section "Monitor"
        Identifier "DP-4"
        Option "PreferredMode" "2560x1440"
        Option "LeftOf" "DP-1"
    EndSection

    Section "Screen"
        Identifier "Screen0"
        Device "GPU0"
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
      name = "full-system-backup";
      packages = with pkgs; [ gnutar gzip findutils ];
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

        backup Documents /home/dan/Documents &
        backup Downloads /home/dan/Downloads &
        backup open-webui /var/lib/open-webui &
        backup etc /etc &
        backup usr /usr &

        wait
      '';
    }
    {
      script = "/home/dan/Music/download.sh";
      packages = with pkgs; [ gnutar gzip findutils scdl ffmpeg_6-full yt-dlp ];
      name = "download-music";
      schedule = "*-*-* 02:00:00";
    }
  ];
}
