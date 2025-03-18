{ pkgs }: { hostName }: inside:

inside // {
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
}
