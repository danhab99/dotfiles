import ../module.nix
{
  name = "neovim";

  output = { pkgs, ... }: {
    homeManager = {
      programs.neovim = {
        enable = true;

        coc = {
          enable = true;

        };

        plugins = with pkgs.vimPlugins; [
          fzfWrapper
          vim-polyglot
          vim-closetag
          vim-css-color
          blamer-nvim
          vim-gitgutter
          lightline-vim
          nerdtree
          lightline-vim
          nvim-surround
          goyo-vim
          vim-move
          undotree
          neoformat
          vim-commentary
          vim-fugitive
          onedarkpro-nvim
          ctrlp-vim
          tagbar
        ];

        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;

        extraConfig = builtins.readFile ./vimrc;
      };
    };
  };
}

