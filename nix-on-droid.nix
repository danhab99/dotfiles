{ ... }:

{
  imports = [
    (import ./modules/select.nix "droidModule")
  ];

  config = {
    home-manager.useGlobalPkgs = true;
    #home-manager.useUserPackage = true;

    module = {
      fzf.enable = true;
      git = {
        enable = true;
        email = "dan.habot@gmail.com";
        signingKey = "A7FB97D9F0C45B63";
      };
      gnupg.enable = true;
      neovim.enable = true;
      nix.enable = true;
      ranger.enable = true;
      secrets.enable = true;
      zoxide.enable = true;
      zsh.enable = true;
      
      all-packages.enable = true;
      droid-packages.enable = true;
      essential-packages.enable = true;
    };

    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    android-integration.termux-open.enable = true;
    android-integration.termux-open-url.enable = true;
    android-integration.termux-reload-settings.enable = true;
    android-integration.termux-setup-storage.enable = true;
    android-integration.xdg-open.enable = true;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home-manager.config.home.stateVersion = "24.05"; # Please read the comment before changing.
    system.stateVersion = "24.05";
  };
}
