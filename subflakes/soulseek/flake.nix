{
  description = "soulseek";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "soulseek";

    output = { pkgs, ... }: {
      packages = with pkgs; [
        nicotine-plus
      ];

      homeManager = { };

      nixos = {
        networking.firewall = {
          allowedTCPPorts = [ 2242 ];
          allowedUDPPorts = [ 2242 ];
        };
      };
    };
  };
}
