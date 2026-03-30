import ../module.nix
{
  name = "virtualbox";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {

    };

    nixos = {
      virtualisation.virtualbox = {
        host.enable = true;
      };

      users.extraGroups.vboxusers.members = [ "dan" ];
    };
  };
}

