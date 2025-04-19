{ name, options ? { ... }: { }, output }:
{ lib, config, pkgs, ... }:
let
  cfg = config.module.${name};
  out = output { inherit lib config pkgs cfg; };
in
{
  options.module.${name} = (options { inherit lib; }) // {
    enable = lib.mkEnableOption name;
  };

  config = lib.mkIf cfg.enable (
    (if out ? nixos then out.nixos else { }) // 
    {
      environment.systemPackages = if (out ? packages) then out.packages else [ ];
      home-manager.users.dan.config = if (out ? homeManager) then out.homeManager else { };
    }
  );
}
