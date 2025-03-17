{ pkgs, ... }:

{
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

  home.sessionVariables = with pkgs; {
    EDITOR = vim-full + "/bin/vim";
    BROWSER = brave + "/bin/brave";
    GIT_PAGER = bat + "/bin/bat";
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
