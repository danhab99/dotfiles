import ../_module.nix
{
  name = "kdeconnect";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      services.kdeconnect = {
        enable = true;
        indicator = true;
      };
    };

    nixos = {
      networking.firewall = {
        allowedTCPPorts = builtins.genList (x: x + 1714) 51;
        allowedUDPPorts = builtins.genList (x: x + 1714) 51;
      };
    };
  };
}
