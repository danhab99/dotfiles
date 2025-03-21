# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

in lib.mkModule {
  name =  "threedtools";

  output = { ... }: {
    packages = with pkgs; [ 
      freecad
      blender
      bambu-studio
    ];
  }
}
