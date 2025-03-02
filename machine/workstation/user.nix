{ ... }:

{
  imports = [ ../../modules/default.nix ./xserver.nix ];

  config.modules = {
    appimage.enable = true;
    git.enable = true;
    kde.enable = true;
    openssh.enable = true;
    printing.enable = true;
    steam.enable = true;
    xorg.enable = true;
    gnupg.enable = true;
    picom.enable = true;
    ratbag.enable = true;
    urxvt.enable = true;
    zoxide.enable = true;
    flipperzero.enable = true;
    i3 = {
      enable = true;
      configFile = ./i3/config;
    };
    ollama.enable = true;
    pipewire.enable = true;
    secrets.enable = true;
    vim.enable = true;
    zsh.enable = true;
  };

  home.files = import ./files.nix;
}

