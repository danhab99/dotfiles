import ../module.nix
{
  name = "wireguard";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      wireguard-tools
    ];

    homeManager = { };

    nixos = {
      networking.firewall.allowedUDPPorts = [ 51820 ];

      # Enable IP forwarding and NAT if needed
      boot.kernel.sysctl."net.ipv4.ip_forward" = true;

      networking.nat = {
        enable = true;
        externalInterface = "eth0";
        internalInterfaces = [ "wg0" ];
      };
    };
  };
}
