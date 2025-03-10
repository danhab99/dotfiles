{ config, option, ... }:

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
    rofi.enable = true;
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
    fzf.enable = true;
  };

  config.home.file = {
    ".config/g600" = {
      source = ./g600;
      recursive = true;
    };

    ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
  };
}
