{ ... }:

{
  imports = [
    ./modules/droid.nix
  ];

  modules = {
    zsh.enable = true;
  };
}
