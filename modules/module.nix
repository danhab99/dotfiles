{ name, options ? { ... }: { }, output }:
inputs@{ lib, config, pkgs, ... }:
let
  cfg = config.module.${name};
  out = output (inputs // { inherit cfg; });

  enabledNixos = out.nixos or { };
  enabledPackages = out.packages or [ ];
  enabledHomemanager = out.homeManager or { } ;

  enabledHomemanagerForUses =
    let
      pairs = builtins.map
        (user: {
          name = user;
          value = enabledHomemanager;
        })
        cfg.forUsers;
    in
    builtins.listToAttrs pairs;
in
{
  options.module.${name} = (options { inherit lib; }) // {
    enable = lib.mkEnableOption name;
    forUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "dan" ];
    };
  };

  config = lib.mkIf cfg.enable (
    enabledNixos //
    {
      environment.systemPackages = enabledPackages;
      home-manager.users = enabledHomemanagerForUses;
    }
  );
}
