{ ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    appimage.enable = true;
    git.enable = true;
    gnupg.enable = true;
    i3 = {
      enable = true;
      configFile = ./i3/config;
    };
    ollama = {
      enable = false;
      repoDir = "/bucket/ollama";
    };
    picom.enable = true;
    urxvt.enable = true;
    vim.enable = true;
    xorg.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
}
