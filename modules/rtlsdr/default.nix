import ../module.nix
{
  name = "rtlsdr";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      gqrx
      audacity
    ];

    nixos = {
      hardware.rtl-sdr.enable = true;
    };
  };
}

