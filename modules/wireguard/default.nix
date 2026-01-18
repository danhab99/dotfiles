import ../module.nix {
  name = "wireguard";

  output =
    { pkgs, config, ... }:
    {
      packages = with pkgs; [
        wireguard-tools
        qrencode
      ];

      nixos = {
        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

        networking.nat = {
          enable = true;
          externalInterface = "eth0"; # adjust if needed
          internalInterfaces = [ "wg0" ];
        };

        networking.firewall = {
          allowedUDPPorts = [ 51820 ];
          checkReversePath = "loose";

          interfaces.wg0 = {
            allowedTCPPorts = [ 20080 ];
            allowedUDPPorts = [ 20080 ];
          };

          extraCommands = ''
            # DNAT: external:20080 → WG peer
            iptables -t nat -A PREROUTING -i ${config.networking.nat.externalInterface} \
              -p tcp --dport 20080 -j DNAT --to-destination 10.100.0.2:20080

            # Forwarding with conntrack (REQUIRED)
            iptables -A FORWARD -i ${config.networking.nat.externalInterface} -o wg0 \
              -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

            iptables -A FORWARD -i wg0 -o ${config.networking.nat.externalInterface} \
              -m state --state ESTABLISHED,RELATED -j ACCEPT
          '';
        };

        networking.wireguard.enable = true;

        networking.wireguard.interfaces.wg0 = {
          ips = [ "10.100.0.1/24" ];
          listenPort = 51820;
          privateKeyFile = "/etc/wireguard/server_private.key";

          peers = [ ];
        };
      };
    };
}
