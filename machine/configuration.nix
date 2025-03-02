{ pkgs, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  time.timeZone = "America/New_York";

  security.rtkit.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [ swt nix-ld ];

  environment.variables = with pkgs; {
    LD_LIBRARY_PATH = "${swt}/lib:$LD_LIBRARY_PATH";
  };

  environment.localBinInPath = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  fonts.packages = with pkgs.nerd-fonts; [ fira-code iosevka mononoki ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.nixos-cli = { enable = true; };

  stylix.base16Scheme =
    "${pkgs.base16-schemes}/share/themes/gruvbox-dark-pale.yaml";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ gtk3 glibc swt freetype ];
}
