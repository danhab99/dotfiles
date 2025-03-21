{ name, options ? { ... }: { }, output }:
{ lib, config, pkgs, ... }:
let
  # cfg = lib.config.module.${name};
  cfg = config.module.${name};
  out = output { inherit cfg lib config pkgs; };
in
{
  options.module.${name} = (options { inherit lib; }) // {
    enable = lib.mkEnableOption name;
  };

  config = (if out ? nixos then out.nixos else { }) // {
    environment.systemPackages = if (out ? packages) then out.packages else [ ];

    home-manager.users.dan.config = if (out ? homeManager) then out.homeManager else { };
  };
}
