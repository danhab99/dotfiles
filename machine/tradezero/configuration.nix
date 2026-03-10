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
      enable = false;
      i3blocksConfig = ./i3blocks.conf;
      screen = [
        "DP-3-2"
        "DP-3-3-1"
        "DP-3-1"
      ];
      defaultLayoutScript = "auto.sh";
      fontSize = 12.0;
    };
    sway = {
      enable = true;
      screen = [
        "DP-3-2"
        "DP-3-3-1"
        "DP-3-1"
      ];
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
    sddm.enable = false;
    secrets.enable = true;
    ssh.enable = true;
    steam.enable = false;
    threedtools.enable = false;
    timezone.enable = true;
    urxvt.enable = false;
    wayland = {
      enable = true;
      videoDrivers = [
        "displaylink"
        "modesetting"
      ];
    };
    xorg = {
      enable = false;
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
    kvm-resilience = {
      enable = true;
      usbHubVendors = [ "0bda" "05e3" "1a40" ];
      enableThunderboltHotplug = true;
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

  swayConfig =
    { mod }:
    {
      keybindings = {
        "${mod}+Ctrl+Return" = "exec rm -f /tmp/workdir && foot";
        "${mod}+Shift+d" = "exec wlr-randr";
      };
    };

  xserver = "";

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

  raw = { pkgs, ... }: {
    services = {
      twingate = {
        enable = true;
      };
      blueman.enable = true;

      # Configure TLP to completely disable USB autosuspend
      tlp.settings = {
        USB_AUTOSUSPEND = 0;
        USB_DENYLIST = "0bda:0411 0bda:5411 05e3:0626 05e3:0610 1a40:0801";
      };
    };
  };

  aliases = pkgs: {
    restart-display = "sudo systemctl restart greetd.service";
  };
}
