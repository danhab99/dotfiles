import ../module.nix
{
  name = "soulseek";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      nicotine-plus
    ];

    homeManager = {

    };

    nixos = {

        networking.firewall = {
          allowedTCPPorts = [ 2242 ];
          allowedUDPPorts = [ 2242 ];
        };
    };
  };
}

