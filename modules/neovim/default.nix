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
          blamer-nvim
          coc-clangd
          coc-css
          coc-docker
          coc-git
          coc-go
          coc-html
          coc-java
          coc-json
          coc-markdownlint
          coc-pyright
          coc-rust-analyzer
          coc-sh
          coc-tailwindcss
          coc-toml
          coc-tsserver
          coc-yaml
          ctrlp-vim
          fzf-lua
          goyo-vim
          lightline-vim
          neoformat
          nerdtree
          nvim-surround
          onedarkpro-nvim
          tagbar
          undotree
          vim-closetag
          vim-commentary
          vim-css-color
          vim-fugitive
          vim-gitgutter
          vim-move
          vim-polyglot
          telescope-nvim
          transparent-nvim
        ];

        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;

        extraConfig = builtins.readFile ./vimrc;
        extraLuaConfig = builtins.readFile ./neovim.lua;
      };
    };
  };
}

