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

  users.users.dan = {
    isNormalUser = true;
    description = "dan";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
    shell = pkgs.zsh;
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

  environment.systemPackages = with pkgs; [
    swt
    nix-ld
    gnupg
    pinentry-curses
    pass
  ];

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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = "10000000";
      max-cache-ttl = "10000000";
    };
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
