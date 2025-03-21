{ pkgs, ... }:

{
  imports = [ ../../modules/default.nix ];

  config.module = {
    appimage.enable = true;
    docker.enable = true;
    font.enable = true;
    fzf.enable = true;
    git.enable = true;
    gnupg.enable = true;
    i18n.enable = true;
    i3 = { enable = true; };
    nix.enable = true;
    ollama = { enable = false; };
    packages.enable = true;
    picom.enable = true;
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
    vim.enable = true;
    xorg = { enable = true; videoDriver = "modesetting"; };
    zoxide.enable = true;
    zsh.enable = true;
  };
}
