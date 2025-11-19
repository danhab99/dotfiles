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
    cli-notes.enable = true;
    displaycal.enable = false;
    docker.enable = true;
    droid-packages.enable = false;
    font.enable = true;
    fzf.enable = true;
    gestures.enable = false;
    git.enable = true;
    gnupg.enable = true;
    i18n.enable = true;
    i3.enable = true;
    kde.enable = false;
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
    vim.enable = true;
    vscode.enable = true;
    watchdog.enable = false;
    wireguard.enable = false;
    xdg.enable = true;
    xorg.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
}
