import ../_module.nix {
  name = "ratbag";
  requires = {
    logitech-g600-rs.url = "github:danhab99/logitech-g600-rs/main";
  };

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
