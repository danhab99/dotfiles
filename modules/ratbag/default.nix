import ../module.nix {
  name = "ratbag";

  output =
    { pkgs, logitech-g600-rs, ... }:
    {
      packages = with pkgs; [
        libratbag
        logitech-g600-rs.packages.x86_64-linux.default
      ];

      nixos.services.ratbagd = {
        enable = true;
      };
    };
}
