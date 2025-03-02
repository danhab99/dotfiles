{ ... }:
let
  allDirs = builtins.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
  imports = builtins.mapAttrs (_: path: import (./. + "/${path}")) allDirs;
in
{
  # # This value determines the NixOS release from which the default
  # # settings for stateful data, like file locations and database versions
  # # on your system were taken. It‘s perfectly fine and recommended to leave
  # # this value at the release version of the first install of this system.
  # # Before changing this value read the documentation for this option
  # # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "24.05"; # Did you read the comment?
  home.stateVersion = "24.05";
  inherit imports;
}
