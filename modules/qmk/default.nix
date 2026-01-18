import ../module.nix {
  name = "qmk";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        qmk
        qmk_hid
        qmk-udev-rules
        vial
      ];

      nixos = {
        hardware.keyboard.qmk.enable = true;
      };
    };
}
