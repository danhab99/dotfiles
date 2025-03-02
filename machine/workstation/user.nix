{ ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    appimage.enable = true;
    flipperzero.enable = true;
    git.enable = true;
    gnupg.enable = true;
    i3 = {
      enable = true;
      configFile = ./i3/config;
    };
    kde.enable = true;
    ollama = {
      enable = true;
      repoDir = "/bucket/ollama";
    };
    openssh.enable = true;
    picom.enable = true;
    pipewire.enable = true;
    printing.enable = true;
    ratbag.enable = true;
    secrets.enable = true;
    steam.enable = true;
    urxvt.enable = true;
    vim.enable = true;
    xorg.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
}
