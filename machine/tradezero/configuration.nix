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
      screen = [ "DP-3-3-1" "DP-3-1" "DP-3-2" ]; # home desk
      defaultLayoutScript = "home-desk.sh";
      fontSize = 12;
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
      videoDrivers = [ "displaylink" "modesetting" ];
      extraConfig = ''
        urxvt*depth: 32
        urxvt*blurRadius: 0
        urxvt*transparent: true
        urxvt*tintColor: #525252
      '';
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
      source-path = "~/Documents/bash/notes";
    };

    all-packages.enable = true;
    nixos-packages.enable = true;
  };

  hostName = "tradezero";

  i3Config = { mod }: {
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

  jobs = { pkgs }: [
    {
      name = "transcribe-eod";
      script = "/home/dan/Videos/run-transcribe.sh";
      schedule = "Mon,Tue,Wed,Thu *-*-* 22:00:00";
      packages = with pkgs; [ whisperx ffmpeg_6-full curl wget jq ];
    }
  ];

  nixos.services = {
    twingate.enable = true;
    blueman.enable = true;

    udev.extraRules = ''
      # Disable autosuspend for Logitech webcam (046d:0825)
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="0825", TEST=="power/control", ATTR{power/control}="on"

      # Disable autosuspend for GenesysLogic hub (05e3:0610)
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05e3", ATTR{idProduct}=="0610", TEST=="power/control", ATTR{power/control}="on"
    '';
  };
}
