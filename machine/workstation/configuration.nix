import ../machine.nix
{
  hostName = "workstation";
  system = "x86_64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    appimage.enable = true;
    docker = {
      enable = true;
      dataRoot = "/data/docker";
    };
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
      enable = false;
      configFile = ./i3/config;
      i3blocksConfig = ./i3blocks.conf;
      screen = [
        "DP-4"
        "DP-0"
        "HDMI-0"
      ];
      defaultLayoutScript = "3screen.sh";
      fontSize = 14.0;
    };
    sway = {
      enable = true;
      screen = [
        "DP-4"
        "DP-0"
        "HDMI-0"
      ];
      fontSize = 14.0;
    };
    nix.enable = true;
    ollama = {
      enable = true;
      repoDir = "/data/ollama";
      models = [
        "deepseek-r1:14b"
        "embeddinggemma"
        "gemma3:latest"
        "llama3.1:8b"
        "qwen3:latest"
      ];
      enableGpu = true;
    };
    printing.enable = true;
    ratbag.enable = true;
    sddm.enable = false;
    secrets.enable = true;
    ssh = {
      enable = true;
      enableFail2Ban = true;
    };
    steam.enable = true;
    threedtools.enable = true;
    timezone.enable = true;
    urxvt.enable = false;
    wayland = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    xorg = {
      enable = false;
      videoDrivers = [ "nvidia" ];
      extraConfig = ''
        urxvt*depth: 32
        urxvt*blurRadius: 10
        urxvt*transparent: true
        urxvt*tintColor: #525252
      '';
      fontSize = 21;
    };
    kvm-resilience = {
      enable = true;
      usbHubVendors = [ "0bda" "05e3" "1a40" ];
      enableThunderboltHotplug = false;
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
    wireguard.enable = false;
    vox = {
      enable = true;
      inputMic = "alsa_input.usb-046d_0825_9476ED00-02.mono-fallback";
    };
    ev-cmd = {
      enable = true;
      devicePath = "/dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd";
      deviceName = "LingYao ShangHai Thumb Keyboard";
    };
    g600 = {
      enable = true;
      devicePath = "/dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd";
      deviceName = "LingYao ShangHai Thumb Keyboard";
    };
    openclaw.enable = true;
    nginx.enable = true;
    kdeconnect.enable = true;
    rofi.enable = true;
    waybar.enable = true;
    foot = {
      enable = true;
      fontSize = 14.0;
    };

    all-packages.enable = true;
    nixos-packages.enable = true;
    my-packages.enable = true;
  };

  raw = {
    # Enable binfmt emulation for building ARM images
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  swayConfig =
    { mod }:
    {
      keybindings = {
        "${mod}+Ctrl+Return" = "exec rm -f /tmp/workdir && foot";
      };
    };

  xserver = "";

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

  jobs =
    { pkgs }:
    [
      {
        name = "full-system-backup";
        packages = with pkgs; [
          gnutar
          gzip
          findutils
        ];
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
        packages = with pkgs; [
          gnutar
          gzip
          findutils
          scdl
          ffmpeg_6-full
          yt-dlp
        ];
        name = "download-music";
        schedule = "*-*-* 02:00:00";
      }
    ];

  output = (system: inputs@{ nixpkgs, axelera-driver, ... }: modules: (nixpkgs.lib.nixosSystem {
    inherit system;

    modules = modules ++ [
      axelera-driver.nixosModules.default
    ];

    specialArgs = inputs;
  }));
}
