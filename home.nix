{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dan";
  home.homeDirectory = "/home/dan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nerdfonts
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    powerline-fonts
    fira-code
    fontconfig
    ranger
  ]; 

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "fira-code" ];
      sansSerif = [ "fira-code" ];
      serif = [ "fira-code" ];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/g600" = {
      source = ./g600;
      recursive = true;
    };

    # ".config/dunst" = {
    #   source = ./dunst;
    # };

    ".config/i3" = {
      source = ./i3;
      recursive = true;
    };

    ".config/rofi" = {
      source = ./rofi;
      recursive = true;
    };

    ".zshrc" = {
      source = ./zsh/zshrc;
    };

    ".vim/desert256.vim" = {
      source = ./vim/desert256.vim;
    };

    ".vimrc" = {
      source = ./vim/vimrc;
    };

    ".bash_aliases" = {
      source = ./bash/bash_aliases;
    };

    ".bash_paths" = {
      source = ./bash/bash_paths;
    };

    ".bash_profile" = {
      source = ./bash/bash_profile;
    };

    ".bashrc" = {
      source = ./bash/bashrc;
    };

    ".gitignore" = {
      source = ./git/gitignore;
    };

    ".gitconfig" = {
      source = ./git/gitconfig;
    };

    ".Xdefaults" = {
      source = ./X/Xdefaults;
    };

    ".Xresources" = {
      source = ./X/Xresources;
    };

    ".urxvt/ext" = {
      source = ./urxvt/ext;
      recursive = true;
    };

    ".config/ev-cmd.toml" = {
      source = ./ev-cmd/ev-cmd.toml;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.ranger = {
    enable = true;
  };
}
