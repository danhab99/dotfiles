{
  description = "wireguard NixOS module";

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
      name = "wireguard";
      inherit inputs;

      options = { lib }:
        with lib;
        {
          enable = mkEnableOption "wireguard module";

          interface = mkOption {
            type = types.str;
            default = "wg0";
            description = "WireGuard interface name.";
          };

          listenPort = mkOption {
            type = types.port;
            default = 51820;
            description = "UDP port the WireGuard server listens on.";
          };

          serverAddress = mkOption {
            type = types.str;
            default = "10.100.0.1/24";
            description = "IP address (with prefix) assigned to the server interface.";
          };

          publicEndpoint = mkOption {
            type = types.str;
            description = "Public DNS name or IP clients should use as endpoint.";
          };

          privateKeyFile = mkOption {
            type = types.str;
            default = "/etc/wireguard/server.key";
            description = ''
              Path to the server private key file.
              Must be provisioned out-of-band — never store the key in your NixOS config.
              Generate with: install -m 0600 /dev/null /etc/wireguard/server.key && wg genkey > /etc/wireguard/server.key
            '';
          };

          externalInterface = mkOption {
            type = types.str;
            description = "Upstream network interface used for NAT masquerading.";
          };

          openFirewall = mkOption {
            type = types.bool;
            default = true;
            description = "Open the WireGuard UDP port in the firewall.";
          };

          allowedTCPPorts = mkOption {
            type = types.listOf types.port;
            default = [ ];
            description = "TCP ports reachable from WireGuard clients on the VPN interface.";
          };
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            wireguard-tools
            qrencode # used by wg-new-user.sh for QR code output
          ];

          nixos = {
            # Enable IP forwarding so VPN clients can reach the LAN / internet.
            boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

            environment.etc = lib.mkIf (cfg.publicEndpoint != "") {
              "wireguard/public-endpoint".text = cfg.publicEndpoint;
            };

            networking.firewall = {
              allowedUDPPorts = lib.mkIf cfg.openFirewall [ cfg.listenPort ];
              trustedInterfaces = [ cfg.interface ];
              interfaces.${cfg.interface}.allowedTCPPorts = cfg.allowedTCPPorts;
            };

            # NAT: masquerade VPN traffic out through the upstream interface.
            networking.nat = {
              enable = true;
              internalInterfaces = [ cfg.interface ];
              externalInterface = cfg.externalInterface;
            };

            networking.wg-quick.interfaces.${cfg.interface} = {
              address = [ cfg.serverAddress ];
              listenPort = cfg.listenPort;
              privateKeyFile = cfg.privateKeyFile;
            };
          };
        };
    };
}
