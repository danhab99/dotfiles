{ ... }:

{
  imports = [ ../../modules/default.nix ];

  config.modules = {
    fzf.enable = true;
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
    rofi.enable = true;
    urxvt.enable = true;
    vim.enable = true;
    xorg.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };

  config = {
    home.file = {
      # ".Xdefaults" = { source = ./Xdefaults; };
      # ".Xresources" = { source = ./Xresources; };
      ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
      ".config/g600" = {
        source = ./g600;
        recursive = true;
      };
    };

    xsession.windowManager.i3.config = {
      keybindings = { "$mod+Ctrl+Return" = "exec rm /tmp/workdir && urxvt"; };
    };

    xresources.extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./Xresources)
      (builtins.readFile ./Xdefaults)
    ];
  };
}
