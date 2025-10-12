import ../machine.nix
{
  hostName = "laptop";

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
      signingKey = "0x9D575F7BFF5A6CB4";
      email = "dan.habot@gmail.com";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = true;
      i3blocksConfig = ./i3blocks.conf;
      screen = [ "eDP-1" ];
    };
    nix.enable = true;
    ollama.enable = false;
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
        urxvt*depth: 0
        urxvt*blurRadius: 0
        urxvt*transparent: true
        urxvt*tintColor: #555
      '';
    };
    zoxide.enable = true;
    zsh.enable = true;
    thinkpad.enable = true;
    neovim.enable = true;
    ranger.enable = true;
    obs.enable = true;
    audio = {
      enable = true;
      enableBluetooth = true;
      enableJACK = true;
    };
    watchdog.enable = true;
    gestures = {
      enable = true;
      devicePath = "/dev/input/by-path/platform-i8042-serio-1-event-mouse";
    };
    vscode.enable = true;
    tmux.enable = true;

    all-packages.enable = true;
    nixos-packages.enable = true;
  };

  i3Config = { mod }: {
    keybindings = {
      "Mod4+Shift+Return" = "exec urxvt -e ssh -S /tmp/ssh-master-desktop.sock desktop";
    };
  };

  jobs = { pkgs }: [
    {
      name = "ssh-desktop-channel";
      schedule = "*-*-*";
      script = ''
        rm -f /tmp/ssh-master-desktop.sock
        ${pkgs.openssh}/bin/ssh -N -M -S "/tmp/ssh-master-desktop.sock" -L 20080:localhost:20080 desktop
      '';
      packages = [ pkgs.openssh ];
      user = "dan";
    }
  ];
}
