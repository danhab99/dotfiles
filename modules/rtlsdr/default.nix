import ../_module.nix {
  name = "rtlsdr";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        gqrx
        audacity
        sdrpp
      ];

      nixos = {
        hardware.rtl-sdr.enable = true;
      };
    };
}
