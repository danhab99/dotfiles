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
    i3 = { 
      enable = true;
      i3blocksConfig = ./i3blocks.conf;
    };
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
    thinkpad.enable = true;
  };

  config.home-manager.users.dan = {
    xresources.extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./Xresources)
      (builtins.readFile ./Xdefaults)
    ];

    xsession.windowManager.i3.config.keybindings = {
      "Mod4+Shift+Return" = "exec urxvt -e ssh desktop";
    };
  };

  config = {
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };
}
