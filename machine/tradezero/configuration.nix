{ ... }:

{
  imports = [
    ../../modules
    ../../users
  ];

  config = {
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
        screen = [ "DP-2-3-1" "DP-2-1" "DP-2-2" ]; # home desk
      };
      nix.enable = true;
      ollama = {
        enable = true;
        models = [
          "deepseek-r1"
          "gemma3"
          "llama3.3"
          "nomic-embed-text"
          "phi3"
          "qwq"
          "tinyllama"
        ];
      };
      pipewire.enable = true;
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
        videoDriver = "modesetting";
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
      vim.enable = true;
      ranger.enable = true;
      audio = {
        enable = true;
        enableBluetooth = true;
      };
      obs.enable = true;
    };

    home-manager.users.dan = {
      xsession.windowManager.i3.config =
        let
          mod = "Mod4";
        in
        {
          keybindings = {
            "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && urxvt";
            "${mod}+Shift+d" = "exec /home/dan/.screenlayout/restart.sh";
          };
        };
    };

    services.twingate.enable = true;

    services.xserver.config = ''
      Section "InputClass"
      Identifier "keyboard-all"
      Option "XkbOptions" "terminate:ctrl_alt_bksp"
      EndSection
    '';

    services.blueman.enable = true;
    # hardware.bluetooth.enable = true;

  };
}
