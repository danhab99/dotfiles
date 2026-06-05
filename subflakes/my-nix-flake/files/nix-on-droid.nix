{ ... }:

{
  # Droid modules are now injected by flake.nix via allDroidModules
  config = {
    home-manager.useGlobalPkgs = true;
    #home-manager.useUserPackage = true;

    module = {
    };

    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

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
