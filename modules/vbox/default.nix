import ../module.nix {
  name = "vbox";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [

      ];

      nixos = {
        virtualisation.virtualbox.host.enable = true;
        users.extraGroups.vboxusers.members = [ "dan" ];
      };
    };
}
