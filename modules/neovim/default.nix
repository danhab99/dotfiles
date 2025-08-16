import ../module.nix
{
  name = "neovim";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      ctags
      astyle
    ];

    homeManager = {
      home.file.".config/nvim/lua" = {
        source = ./lua;
        enable = true;
        recursive = true;
      };

      programs.neovim = {
        enable = true;

        coc = {
          enable = true;
          settings = {
            "languageserver" = {
              "csharp-ls" = {
                "command" = "csharp-ls";
                # "args" = [ "--stdio" ];
                "filetypes" = [ "cs" ];
                "rootPatterns" = [ "*.csproj" ];
                "trace.server" = "verbose";
              };
            };
            "inlayHint.enable" = false;
          };
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
          coc-lua
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
          onedark-nvim
          onedarkpro-nvim
          tagbar
          telescope-nvim
          transparent-nvim
          undotree
          vim-closetag
          vim-commentary
          vim-css-color
          vim-fugitive
          vim-gitgutter
          vim-move
          vim-polyglot
        ];

        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;
        defaultEditor = true;

        # extraConfig = builtins.readFile ./vimrc;
        extraLuaConfig = builtins.readFile ./lua/neovim.lua;
      };
    };
  };
}
