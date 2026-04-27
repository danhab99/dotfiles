# workstation — plain attrset consumed by machine.nix
{
  hostName = "workstation";
  system = "x86_64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    cachix.enable = true;
    appimage.enable = true;
    docker = {
      enable = true;
      # dataRoot = "/data/docker";
      dataRoot = "/bucket/docker";
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
      enable = true;
      configFile = ./i3/config;
      i3blocksConfig = ./i3blocks.conf;
      screen = [
        "DP-4"
        "HDMI-0"
        "DP-0"
      ];
      defaultLayoutScript = "3screen.sh";
      fontSize = 14.0;
    };
    nix.enable = true;
    ollama = {
      enable = true;
      repoDir = "/bucket/ollama";
      models = [
        "deepseek-r1:14b"
        "embeddinggemma"
        "gemma3:latest"
        "llama3.1:8b"
        "qwen3:latest"
        "opencoder:8b"
        "deepcoder:14b"
        "qwen3.5:9b"
      ];
      enableGpu = true;
    };
    printing.enable = true;
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
    xorg = {
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
      devicePath = "/dev/input/by-id/usb-Logitech_Gaming_Mouse_G600_FED1B7EDC0960017-if01-event-kbd";
      deviceName = "Logitech Gaming Mouse G600 Keyboard";
    };
    openclaw.enable = true;
    nginx.enable = true;
    n8n.enable = true;
    kdeconnect.enable = true;
    rofi.enable = true;
    firefox.enable = true;
    bitwarden.enable = true;
    soulseek.enable = true;

    all-packages.enable = true;
    nixos-packages.enable = true;
    my-packages.enable = true;
  };

  raw = {
    # Enable binfmt emulation for building ARM images
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Disable USB autosuspend to prevent KVM switch power interruptions from
    # putting devices into an unrecoverable state (usb_set_interface -110 loop).
    boot.kernelParams = [
      "usbcore.autosuspend=-1"
      # NVMe resilience: disable power saving states to prevent hangs on a
      # flaky drive controller, and max out I/O timeout so a slow/dying drive
      # doesn't trigger a kernel panic or force a reset mid-session.
      "nvme_core.default_ps_max_latency_x=0"
      "nvme_core.io_timeout=4294967295"
      # PCIe resilience: disable AER so errors from a bad device don't cause
      # machine-check exceptions, and disable ASPM so the PCIe link never
      # enters a low-power state that a flaky device might not wake from.
      "pci=noaer"
      "pcie_aspm=off"
    ];

    # Disable runtime power management for USB hubs (prevents KVM/audio disconnects)
    services.udev.extraRules = ''
      # Disable autosuspend for ALL USB hubs
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", TEST=="power/control", ATTR{power/control}="on"
      # GenesysLogic USB hubs (KVM switch hubs)
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", TEST=="power/control", ATTR{power/control}="on"
      # Feixiang USB HIFI Audio - disable autosuspend to prevent timeout storms
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="262a", TEST=="power/control", ATTR{power/control}="on"
    '';

    # Systemd service for on-demand USB controller reset
    systemd.services.reset-usb = {
      description = "Reset xHCI USB controller to recover from stuck devices";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/bin/sh /etc/nixos/scripts/reset-usb.sh";
      };
    };
  };

  i3Config =
    { mod }:
    {
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
            ${pkgs.findutils}/bin/find /bucket/backup -type f -name "*.tar.gz" -mtime +15 -delete
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

  output = system: inputs@{ nixpkgs, axelera-driver, ... }: modules: (nixpkgs.lib.nixosSystem {
    inherit system;

    modules = modules ++ [
      axelera-driver.nixosModules.default
    ];

    specialArgs = inputs;
  });
}
