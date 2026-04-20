import ../_module.nix {
  name = "neovim";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        ctags
        astyle
        xclip
        xsel
        typescript-language-server
        dart
        prettier
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
                  "rootPatterns" = [ "go.mod" ];
                  "filetypes" = [ "go" ];
                };
                "typescript" = {
                  "command" = "typescript-language-server";
                  "args" = [ "--stdio" ];
                  "filetypes" = [
                    "javascript"
                    "javascriptreact"
                    "javascript.jsx"
                    "typescript"
                    "typescriptreact"
                    "typescript.tsx"
                  ];
                  "rootPatterns" = [
                    "tsconfig.json"
                    "jsconfig.json"
                    "package.json"
                    ".git"
                  ];
                };
                "dart" = {
                  "command" = "dart";
                  "args" = [ "language-server" ];
                  "filetypes" = [
                    "dart"
                  ];
                  "rootPatterns" = [
                    "pubspec.yaml"
                  ];
                };
              };
              "rust-analyzer.server.path" = "rust-analyzer";
              "inlayHint.enable" = false;
              "coc.preferences.formatOnSaveFiletypes" = [
                "javascript"
                "javascriptreact"
                "typescript"
                "typescriptreact"
                "json"
                "html"
                "css"
                "scss"
              ];
              "prettier.onlyUseLocalVersion" = true;
              "prettier.requireConfig" = false;
              "cSpell.userWords" = [
                "callout"
                "chans"
                "clsx"
                "filepath"
                "hasher"
                "msgpack"
                "ollama"
                "openpgp"
                "postgres"
                "sqlite"
                "tempfile"
                "unmarshal"
                "unstage"
                "userless"
                "vlog"
                "watchlist"
              ];
            };
          };

          plugins = with pkgs.vimPlugins; [
            CopilotChat-nvim
            blamer-nvim
            coc-clangd
            coc-css
            coc-docker
            coc-git
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
            coc-yaml
            coc-prettier
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
            vim-just
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
