{ ... }:

{
  services.udev = {
    enable = true;
    extraRules = ''
      KERNEL=="event*", NAME="input/%k", MODE="660", GROUP="input"
    '';
  };
}
