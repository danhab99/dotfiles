{ ... }:

{
  imports = [ ../../modules/default.nix ];

  config.module = {
    appimage.enable = true;
    docker.enable = true;
    font.enable = true;
    fzf.enable = true;
    git = {
      enable = true;
      signingKey = "0x9D575F7BFF5A6CB4";
      email = "dan.habot@gmail.com";
    };
    gnupg.enable = true;
    i18n.enable = true;
    i3 = {
      enable = true;
      i3blocksConfig = ./i3blocks.conf;
    };
    nix.enable = true;
    ollama.enable = false; 
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
    xorg = {
      enable = true;
      videoDriver = "modesetting";
    };
    zoxide.enable = true;
    zsh.enable = true;
    thinkpad.enable = true;
    vim.enable = true;
    ranger.enable = true;
  };

  config.home-manager.users.dan = {
    xresources.extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./Xresources)
      (builtins.readFile ./Xdefaults)
    ];

    xsession.windowManager.i3.config.keybindings = {
      "Mod4+Shift+Return" = "exec urxvt -e ssh desktop";
    };

    programs.zsh.shellAliases = {
      pull = "rsync -avz \"desktop:$(pwd)/$1\" .";
      push = "rsync -avz \"$1\" \"desktop:$(pwd)/\"";
    };
  };
}
