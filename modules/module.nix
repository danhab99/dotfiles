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

      getOpt = f: f { inherit lib; };
      moduleOptions = getOpt options;
      deviceOptions = getOpt deviceSpecificOptions;
    in
    {
      options.module.${name} = moduleOptions // deviceOptions // {
        enable = lib.mkEnableOption name;
      };
    } // (module { inherit cfg lib nixos packages homeManager; });
in
{

  nixosModule = mkDevice {
    deviceSpecificOptions = { lib }: with lib; {
      forUsers = mkOption {
        type = types.listOf types.str;
        default = [ "dan" ];
      };
    };

    module = { cfg, lib, nixos, packages, homeManager }:
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
      {
        config = lib.mkIf cfg.enable (
          nixos //
          {
            environment.systemPackages = packages;
            home-manager.users = homeManagerForUses;
          }
        );
      };
  };

  droidModule = mkDevice {
    module = { cfg, lib, nixos, homeManager, packages }:
      {
        config = lib.mkIf cfg.enable {
          environment.packages = packages;
          home-manager.config = homeManager;
        };
      };
  };
}
