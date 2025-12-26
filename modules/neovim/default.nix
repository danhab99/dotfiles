import ../module.nix
{
  name = "neovim";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      ctags
      astyle
      xclip
      xsel
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
            "suggest.noselect" = false;
            "suggest.enablePreselect" = true;
            "suggest.triggerAfterInsertEnter" = true;
            "suggest.timeout" = 5000;
            "suggest.enablePreview" = true;
            "suggest.floatEnable" = true;
            "diagnostic.errorSign" = "✗";
            "diagnostic.warningSign" = "⚠";
            "diagnostic.infoSign" = "ℹ";
            "diagnostic.hintSign" = "➤";
            "languageserver" = {
              "csharp-ls" = {
                "command" = "csharp-ls";
                "filetypes" = [ "cs" ];
                "rootPatterns" = [ "*.csproj" ];
              }; 
              "go" = {
                "command" = "gopls";
                "rootPatterns" = ["go.mod"];
                "filetypes" = ["go"];
              };
            };
            "rust-analyzer.server.path" = "rust-analyzer";
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
          coc-spell-checker
          coc-tailwindcss
          coc-toml
          coc-tsserver
          coc-yaml
          CopilotChat-nvim
          ctrlp-vim
          fzf-lua
          goyo-vim
          lightline-vim
          neoformat
          nerdtree
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
          vim-polyglot
          vim-surround
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
