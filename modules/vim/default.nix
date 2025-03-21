# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "vim";

  output = { ... }: {
    packages = with pkgs; [ vim-full ];

    homeManager = {
      home.sessionVariables = { EDITOR = pkgs.vim-full + "/bin/vim"; };

      home.file = {
        ".vim/desert256.vim" = {
          source = builtins.fetchurl {
            url = "http://hans.fugal.net/vim/colors/desert.vim";
            sha256 =
              "0f6f2754ed4b49104f2c73e69c022d66c860fd675a866589fe471bcfca87ba1e";
          };
        };

        ".vimrc" = { source = ./vimrc; };
      };
    };
  };
}
