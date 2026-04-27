import ../_module.nix
{
  name = "cachix";

  output = { lib, pkgs, ... }:
    let
      folder = ./caches;
      filterCaches = name: value: value == "regular" && lib.hasSuffix ".nix" name;
      cacheFiles = lib.filterAttrs filterCaches (builtins.readDir folder);
      cacheConfigs = map (name: import (folder + "/${name}")) (builtins.attrNames cacheFiles);
      allSubstituters = lib.concatLists (map (c: c.nix.settings.substituters or [ ]) cacheConfigs);
      allTrustedKeys = lib.concatLists (map (c: c.nix.settings."trusted-public-keys" or [ ]) cacheConfigs);
    in
    {
      packages = [ ];

      homeManager = { };

      nixos = {
        nix.settings.substituters = [ "https://cache.nixos.org/" ] ++ allSubstituters;
        nix.settings.trusted-public-keys = allTrustedKeys;
      };
    };
}

