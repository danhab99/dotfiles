import ../machine.nix
{
  hostName = "uconsole";
  system = "aarch64-linux";

  users = {
    dan.enable = true;
  };

  module = {
    all-packages.enable = true;
    appimage.enable = true;
    audio.enable = true;
    docker.enable = true;
    droid-packages.enable = false;
    font.enable = true;
    fzf.enable = true;
    gestures.enable = false;
    git = {
      enable = true;
      signingKey = "";
      email = "dan.habot@gmail.com";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = true;
      i3blocksConfig = ./i3blocks.conf;
      screen = [ "eDP-1" ]; 
      defaultLayoutScript = "";
      fontSize = 12.0;
    };
    libreoffice.enable = false;
    metis.enable = false;
    neovim.enable = true;
    nix.enable = true;
    nixos-packages.enable = true;
    nvidia.enable = false;
    obs.enable = true;
    ollama.enable = false;
    printing.enable = false;
    qmk.enable = false;
    ranger.enable = true;
    ratbag.enable = false;
    redshift.enable = false;
    rofi.enable = true;
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
    vscode.enable = true;
    watchdog.enable = false;
    wireguard.enable = false;
    xdg.enable = true;
    xorg = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      extraConfig = ''
        urxvt*depth: 32
        urxvt*blurRadius: 0
        urxvt*transparent: true
        urxvt*tintColor: #525252
      '';
      fontSize = 12;
    };
    zoxide.enable = true;
    zsh.enable = true;
  };

  nixos = {
    # Basic bootloader for ARM - using generic extlinux for compatibility
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible.enable = true;
    
    # Enable firmware
    hardware.enableRedistributableFirmware = true;
  };

  extraNixosModules = { nixos-uconsole, ... }: [
    nixos-uconsole.nixosModules.default
    nixos-uconsole.nixosModules."kernel-6.1-potatomania"
  ];
}
