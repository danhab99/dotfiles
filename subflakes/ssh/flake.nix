{
  description = "ssh NixOS module";

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
      name = "ssh";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "ssh module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [ openssh ];

          nixos = {
            services.openssh = {
              enable = true;
              allowSFTP = true;
              authorizedKeysInHomedir = true;
              settings.PasswordAuthentication = lib.mkForce false;
              settings = {
                X11Forwarding = true;
              };
            };

            networking.firewall = {
              allowedTCPPorts = [ 22 ];
              allowedUDPPorts = [ 22 ];
            };

            services.fail2ban = {
              enable = cfg.enableFail2Ban;

              maxretry = 10;
              bantime = "10h";
            };
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}
