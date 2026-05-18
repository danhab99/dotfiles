{
  description = "nginx NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "nginx";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "nginx module";

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

      output = { pkgs, config, cfg, lib, ... }:
        {
          nixos = {
            services.nginx = {
              enable = true;

              recommendedProxySettings = true;
              recommendedOptimisation = true;
              recommendedGzipSettings = true;

              virtualHosts = lib.mapAttrs
                (_: vhost: {
                  locations."/" = {
                    proxyPass = "http://127.0.0.1:${toString vhost.port}";
                    proxyWebsockets = true;
                  };
                })
                cfg.virtualHosts;
            };
          };
        };
    };
}
