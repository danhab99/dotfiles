{ hostName }:
{ pkgs, ... }: 

{
  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
    shell = pkgs.zsh;
  };

  networking = {
    networkmanager.enable = true;
    inherit hostName;
  };

  environment.localBinInPath = true;

  services.dbus.enable = true;

  services.nixos-cli = { enable = true; };

  boot.tmp.cleanOnBoot = true;

  home-manager.users.dan = {
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
      BROWSER = firefox + "/bin/firefox";
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Please read the comment before changing.
}
