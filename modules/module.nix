{ name, options ? { ... }: { }, output }:
{ lib, config, pkgs, ... }:
let
  cfg = config.module.${name};
  out = output { inherit lib config pkgs cfg; };

  enabledNixos = if out ? nixos then out.nixos else { };
  enabledPackages = if (out ? packages) then out.packages else [ ];
  enabledHomemanager = if (out ? homeManager) then out.homeManager else { };

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
      home-manager.users.dan.config = enabledHomemanager;
    }
  );
}
