import ../module.nix {
  name = "sddm";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        # ...
      ];

      nixos.services.displayManager = {
        sddm.enable = true;
        # defaultSession = "none+i3";
      };
    };
}
