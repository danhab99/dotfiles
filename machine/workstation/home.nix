{ pkgs, ... }:

{
  imports = [ ../../programs/zsh.home.nix ../../programs/git.home.nix ];

  home.username = "dan";
  home.homeDirectory = "/home/dan";

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "fira-code" ];
      sansSerif = [ "fira-code" ];
      serif = [ "fira-code" ];
    };
  };

  home.file = import ./files.nix { };

  home.sessionVariables = {
    EDITOR = pkgs.vim-full + "/bin/vim";
    BROWSER = pkgs.brave + "/bin/brave";
    VI_MODE_SET_CURSOR = "true";
    VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = "true";
  };

  programs.home-manager.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
}
