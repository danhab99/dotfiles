import ../machine.nix rec {
  hostName = "uconsole";
  system = "aarch64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    all-packages.enable = false; # Disable for SD image build
    appimage.enable = false;
    audio.enable = false;
    docker.enable = false;
    droid-packages.enable = false;
    font.enable = false;
    fzf.enable = true;
    gestures.enable = false;
    git = {
      enable = true;
      email = "dan.habot@gmail.com";
      signingKey = "";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = false;
      screen = [ "eDP-1" ];
      defaultLayoutScript = "";
      fontSize = 14.0;
      i3blocksConfig = ../workstation/i3blocks.conf;
    };
    libreoffice.enable = false;
    metis.enable = false;
    neovim.enable = true;
    nix.enable = true; # Keep nix tools
    nixos-packages.enable = false;
    nvidia.enable = false;
    obs.enable = false;
    ollama.enable = false;
    printing.enable = false;
    qmk.enable = false;
    ranger.enable = true;
    ratbag.enable = false;
    redshift.enable = false;
    rofi.enable = false;
    rtlsdr.enable = false;
    sddm.enable = false;
    secrets.enable = true;
    ssh.enable = true; # Keep SSH for remote access
    steam.enable = false;
    thinkpad.enable = false;
    threedtools.enable = false;
    timezone.enable = true;
    tmux.enable = true;
    urxvt.enable = false;
    vbox.enable = false;
    vim.enable = false;
    vscode.enable = false;
    watchdog.enable = false;
    wireguard.enable = false;
    xdg.enable = true;
    xorg = {
      enable = false;
      videoDrivers = [ "modesetting" ];
      fontSize = 12;
    };
    zoxide.enable = true;
    zsh.enable = true;
    essential-packages.enable = true;
  };

  isUconsole = true;
}
