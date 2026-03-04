import ../module.nix {
  name = "nginx";

  options =
    { lib }:
    with lib;
    {
      virtualHosts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              port = mkOption {
                type = types.port;
                description = "Local port to reverse proxy to.";
              };
            };
          }
        );
        default = { };
        description = "Virtual hosts to register as nginx reverse proxies.";
      };
    };

  output =
    { cfg, lib, ... }:
    {
      packages = [ ];

      nixos = {
        services.nginx = {
          enable = true;

          recommendedProxySettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;

          virtualHosts = lib.mapAttrs (_: vhost: {
            locations."/" = {
              proxyPass = "http://127.0.0.1:${toString vhost.port}";
              proxyWebsockets = true;
            };
          }) cfg.virtualHosts;
        };

      };
    };
}
