# uconsole — plain attrset consumed by machine.nix
{
  hostName = "uconsole";
  system = "aarch64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    cachix.enable = true;
    all-packages.enable = false;
    appimage.enable = true;
    audio.enable = false;
    docker.enable = false;
    droid-packages.enable = false;
    font.enable = true;
    fzf.enable = true;
    gestures.enable = false;
    git = {
      enable = true;
      email = "dan.habot@gmail.com";
      # signingKey = "ed25519/0x92ECE5191F6421F8";
      signingKey = "0x92ECE5191F6421F8";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = true;
      screen = [ "eDP-1" ];
      defaultLayoutScript = "normal.sh";
      fontSize = 12.0;
      i3blocksConfig = ../laptop/i3blocks.conf;
      modKey = "Mod1";
      altModKey = "Mod2";
    };
    libreoffice.enable = false;
    neovim.enable = true;
    nix = {
      enable = true;
      remoteBuild = true;
    };
    nixos-packages.enable = false;
    nvidia.enable = false;
    obs.enable = false;
    ollama.enable = false;
    printing.enable = false;
    qmk.enable = false;
    ranger.enable = true;
    redshift.enable = false;
    rtlsdr.enable = true;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;
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
      fontSize = 18;
    };
    zoxide.enable = true;
    zsh.enable = true;
    essential-packages.enable = true;
    tty.enable = true;
    meshtastic.enable = true;
    rofi.enable = true;
  };

  output = system: inputs@{ home-manager, nixos-uconsole, ... }: modules: (nixos-uconsole.lib.mkUConsoleSystem {
    inherit modules;
    specialArgs = inputs;
  });

}
