{ name, options ? { ... }: { }, output }:
let
  mkDevice =
    { deviceSpecificOptions ? { lib }: { }
    , module # ? { cfg, lib, nixos, packages, homeManager }: {}
    }: inputs@{ lib, config, ... }:
    let
      cfg = config.module.${name};
      out = output (inputs // { inherit cfg; });

      nixos = out.nixos or { };
      packages = out.packages or [ ];
      homeManager = out.homeManager or { };
      droid = out.droid or { };

      getOpt = f: f { inherit lib; };
      moduleOptions = getOpt options;
      deviceOptions = getOpt deviceSpecificOptions;
    in
    {
      options.module.${name} = moduleOptions // deviceOptions // {
        enable = lib.mkEnableOption name;
      };

      config = lib.mkIf cfg.enable (module { inherit cfg lib nixos packages homeManager droid; });
    };
in
{

  nixosModule = mkDevice {
    deviceSpecificOptions = { lib }: with lib; {
      forUsers = mkOption {
        type = types.listOf types.str;
        default = [ "dan" ];
      };
    };

    module = { cfg, nixos, packages, homeManager, ... }:
      let
        homeManagerForUses =
          let
            pairs = builtins.map
              (user: {
                name = user;
                value = homeManager;
              })
              cfg.forUsers;
          in
          builtins.listToAttrs pairs;
      in
      nixos //
      {
        environment.systemPackages = packages;
        home-manager.users = homeManagerForUses;
      };
  };

  droidModule = mkDevice {
    module = { cfg, lib, nixos, homeManager, packages, droid }:
      droid // 
      {
        environment.packages = packages;
        home-manager.config = homeManager;
      };
  };
}
