{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qflipper
  ];

  hardware.flipperzero.enable = true;
}
