# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "urxvt";

  output = { ... }: {
    packages = with pkgs; [ rxvt-unicode ];

    homeManager = {
      programs.urxvt = {
        enable = true;

        scroll.bar.enable = false;
      };

      home.file = {
        ".urxvt/ext" = {
          source = builtins.fetchGit {
            shallow = true;
            url = "https://github.com/simmel/urxvt-resize-font.git";
            rev = "b5935806f159594f516da9b4c88bf1f3e5225cfd";
          };
          recursive = true;
        };
      };
    };
  };
}
