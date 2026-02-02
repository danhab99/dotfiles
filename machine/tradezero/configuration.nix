import ../machine.nix {
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
      signingKey = "0x3236F7B0CAE0ECE2";
      email = "dhabot@tradezerofintech.com";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = true;
      i3blocksConfig = ./i3blocks.conf;
      # screen = [ "DP-2-3-1" "DP-2-1" "DP-2-2" ]; # home desk
      # screen = [ "eDP-1" "DP-3-3-1" "DP-3-1" "DP-3-2" ]; # laptop + home desk
      # screen = [ "DVI-I-2-2" "eDP-1" "DVI-I-1-1" ];
      screen = [
        "DP-3-3-1"
        "DP-3-1"
        "DP-3-2"
      ];
      defaultLayoutScript = "auto.sh";
      fontSize = 12.0;
    };
    nix.enable = true;
    ollama = {
      enable = true;
      models = [
        "nomic-embed-text"
        "codegemma:2b-code-v1.1-fp16"
        "embeddinggemma"
        "gemma3:7b"
        "mistral:text"
        "qwen3:4b-instruct-2507-fp16"
        "qwen3:4b-thinking-2507-fp16"
      ];
    };
    printing.enable = true;
    ratbag.enable = false;
    rofi.enable = true;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;
    steam.enable = false;
    threedtools.enable = false;
    timezone.enable = true;
    urxvt.enable = true;
    xorg = {
      enable = true;
      videoDrivers = [
        "displaylink"
        "modesetting"
      ];
      extraConfig = ''
        urxvt*depth: 32
        urxvt*blurRadius: 0
        urxvt*transparent: true
        urxvt*tintColor: #525252
      '';
      fontSize = 16;
    };
    zoxide.enable = true;
    zsh.enable = true;
    thinkpad.enable = true;
    # vim.enable = true;
    ranger.enable = true;
    audio = {
      enable = true;
      enableBluetooth = true;
    };
    obs.enable = true;
    neovim.enable = true;
    watchdog.enable = false;
    vscode.enable = true;
    tmux.enable = true;
    cli-notes = {
      enable = true;
      source-path = "~/Documents/cli-notes";
    };
    xdg.enable = true;
    redshift.enable = true;
    vox = {
      enable = true;
      inputMic = "alsa_input.pci-0000_00_1f.3.analog-stereo";
    };

    all-packages.enable = true;
    nixos-packages.enable = true;
    essential-packages.enable = true;
  };

  packages =
    pkgs: with pkgs; [
      twingate
    ];

  hostName = "tradezero";
  system = "x86-64_linux";

  i3Config =
    { mod }:
    {
      keybindings = {
        "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && urxvt";
        "${mod}+Shift+d" = "exec /home/dan/.screenlayout/restart.sh";
      };
    };

  xserver = ''
    Section "InputClass"
    Identifier "keyboard-all"
    Option "XkbOptions" "terminate:ctrl_alt_bksp"
    EndSection
  '';

  jobs =
    { pkgs }:
    [
      {
        name = "transcribe-eod";
        script = "/home/dan/Videos/run-transcribe.sh";
        schedule = "Mon,Tue,Wed,Thu *-*-* 22:00:00";
        packages = with pkgs; [
          whisperx
          ffmpeg_6-full
          curl
          wget
          jq
        ];
      }
    ];

  nixos.services = {
    twingate = {
      enable = true;
    };
    blueman.enable = true;

    # Configure TLP to completely disable USB autosuspend
    tlp.settings = {
      USB_AUTOSUSPEND = 0;  # Completely disable USB autosuspend
      USB_DENYLIST = "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801";  # Your USB hubs
    };

    udev.extraRules = ''
      # Disable autosuspend for ALL USB hubs (prevents KVM/display disconnects)
      # Match on add AND change events to persist settings
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", TEST=="power/control", ATTR{power/control}="on"
      
      # Disable autosuspend for USB network adapters
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="02", TEST=="power/control", ATTR{power/control}="on"
      
      # Specifically target your GenesysLogic hubs by vendor ID
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", TEST=="power/control", ATTR{power/control}="on"
      
      # Target Realtek USB hubs (your USB3.2/2.1 hubs)
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", TEST=="power/control", ATTR{power/control}="on"
      
      # Target VLI hubs
      ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="1a40", TEST=="power/control", ATTR{power/control}="on"
      
      # Disable runtime power management for ALL USB devices under your dock path
      ACTION=="add|change", SUBSYSTEM=="usb", DEVPATH=="*3-1*", TEST=="power/control", ATTR{power/control}="on"
      ACTION=="add|change", SUBSYSTEM=="usb", DEVPATH=="*2-3*", TEST=="power/control", ATTR{power/control}="on"
    '';
  };

  aliases = pkgs: {
    restart-display = "sudo systemctl restart display-manager.service";
  };
}
