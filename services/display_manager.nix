{ ... }:

{
  services.displayManager = {
    sddm.enable = true;
    defaultSession = "none+i3";
  };
}
