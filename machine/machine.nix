{ hostName }:
{ pkgs, ... }: 

{
  networking = {
    networkmanager.enable = true;
    inherit hostName;
  };

  environment.localBinInPath = true;

  services.dbus.enable = true;

  # services.nixos-cli = { enable = true; };

  boot.tmp.cleanOnBoot = true;

  stylix = {
    enable = true;
    # autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml"; # https://tinted-theming.github.io/tinted-gallery/
    polarity = "dark";

    # targets = {
    #   fcitx5.enable = false;
    # };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  home-manager.backupFileExtension = "backup";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Please read the comment before changing.
}
