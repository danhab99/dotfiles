import ../machine.nix rec {
  hostName = "uconsole";
  system = "aarch64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    all-packages.enable = true;  # Disable for SD image build
    appimage.enable = true;
    audio.enable = false;
    docker.enable = true;
    droid-packages.enable = false;
    font.enable = true;
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
      enable = true;
      screen = [ "" ];
      defaultLayoutScript = "";
      fontSize = 14.0;
      i3blocksConfig = ../workstation/i3blocks.conf;
    };
    libreoffice.enable = false;
    metis.enable = false;
    neovim.enable = true;
    nix.enable = true;  # Keep nix tools
    nixos-packages.enable = true;
    nvidia.enable = false;
    obs.enable = false;
    ollama.enable = false;
    printing.enable = false;
    qmk.enable = false;
    ranger.enable = true;
    ratbag.enable = false;
    redshift.enable = false;
    rofi.enable = true;
    rtlsdr.enable = false;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;  # Keep SSH for remote access
    steam.enable = false;
    thinkpad.enable = false;
    threedtools.enable = false;
    timezone.enable = true;
    tmux.enable = true;
    urxvt.enable = true;
    vbox.enable = false;
    vim.enable = false;
    vscode.enable = false;
    watchdog.enable = false;
    wireguard.enable = false;
    xdg.enable = true;
    xorg = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      fontSize = 12;
    };
    zoxide.enable = true;
    zsh.enable = true;
  };
}
