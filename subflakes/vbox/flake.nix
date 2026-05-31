{
  description = "vbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "vbox";

    output = { pkgs, ... }: {
      packages = with pkgs; [

      ];

      nixos = {
        virtualisation.virtualbox.host.enable = true;
        users.extraGroups.vboxusers.members = [ "dan" ];
      };
    };
  };
}
