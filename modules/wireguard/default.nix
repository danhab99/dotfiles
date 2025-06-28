import ../module.nix
{
  name = "wireguard";

  output = { pkgs, config, ... }: {
    packages = with pkgs; [
      wireguard-tools
      qrencode
    ];

    nixos = {
      # enable IP forwarding
      boot.kernel.sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      # NAT for wg0 → external
      networking.nat.enable = true;
      networking.nat.externalInterface = "eth0"; # adjust if needed
      networking.nat.internalInterfaces = [ "wg0" ];

      # firewall
      networking.firewall.allowedUDPPorts = [ 51820 ];
      networking.firewall.allowedTCPPorts = [ 51820 ];

      networking.firewall.interfaces."wg0".allowedTCPPorts = [ 20080 ];
      networking.firewall.interfaces."wg0".allowedUDPPorts = [ 20080 ];

      networking.firewall.extraCommands = ''
        # DNAT from external 20080 → localhost:20080
        iptables -t nat -A PREROUTING -i ${config.networking.nat.externalInterface} \
          -p tcp --dport 20080 -j DNAT --to-destination 127.0.0.1:20080

        # allow forwarding for that traffic
        iptables -A FORWARD -i ${config.networking.nat.externalInterface} -o wg0 \
          -p tcp --dport 20080 -j ACCEPT
        iptables -A FORWARD -i wg0 -o ${config.networking.nat.externalInterface} \
          -p tcp --sport 20080 -j ACCEPT
      '';

      # WireGuard server
      networking.wireguard.enable = true;
      networking.wireguard.interfaces.wg0 = {
        ips = [ "10.100.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/etc/wireguard/server_private.key";
        peers = [
          {
            publicKey = "KJCoPQktZQ+pvIFtuLezj55kAF390x/Xi0OHasUEmmE=";
            allowedIPs = [ "10.100.0.2/32" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
