{ pkgs }: { hostName }: inside:

inside // {
  services.ollama = {
    enable = true;
    acceleration = "cuda";

    environmentVariables = {
      OLLAMA_MODELS = "/bucket/ollama";
    };
  };

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
}
