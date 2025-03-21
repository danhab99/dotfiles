{ lib, config, ... }:

{
  lib.mkModule = {
    name,
    options,
    output,
  }: let 
    cfg = lib.config.modules.git;
    out = output { cfg };
  in {
    options.modules.[name] = { 
      inherit options;
      enable = mkEnableOption name;
    };

    config = out.nixos // {
      environment.systemPackages = out.packages;

      home-manager.users.dan = {
        config = out.homeManager;
      };
    };
  };
}
