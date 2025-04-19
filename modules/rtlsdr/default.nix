import ../module.nix
{
  name = "rtlsdr";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      gqrx
    ];

    nixos = {
      hardware.rtl-sdr.enable = true;
    };
  };
}

