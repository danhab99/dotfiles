{
  description = "rtlsdr";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
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
  };
}
