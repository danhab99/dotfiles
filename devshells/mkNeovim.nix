{ pkgs, ... }:

{ plugins ? [ ]
, coc ? { }
}:

let
  lib = pkgs.lib;

  luaPath = ../modules/neovim/lua;

  basePlugins = with pkgs.vimPlugins; [
    CopilotChat-nvim
    blamer-nvim
    coc-clangd
    coc-docker
    coc-git
    coc-json
    coc-lua
    coc-markdownlint
    coc-sh
    coc-spell-checker
    coc-toml
    coc-yaml
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

  baseCocSettings = {
    "suggest.noselect" = false;
    "suggest.enablePreselect" = true;
    "suggest.triggerAfterInsertEnter" = true;
    "suggest.timeout" = 5000;
    "suggest.enablePreview" = true;
    "suggest.floatEnable" = true;
    # "diagnostic.errorSign" = "✗";
    # "diagnostic.warningSign" = "⚠";
    # "diagnostic.infoSign" = "ℹ";
    # "diagnostic.hintSign" = "➤";
    "inlayHint.enable" = false;
    "cSpell.userWords" = [
      "hasher"
      "msgpack"
      "unmarshal"
      "sqlite"
      "chans"
      "watchlist"
      "callout"
      "ollama"
      "postgres"
    ];
  };

  mergedCoc = lib.recursiveUpdate baseCocSettings coc;

  cocJson = pkgs.writeText "coc-settings.json"
    (builtins.toJSON mergedCoc);

  extraLua =
    if builtins.pathExists (luaPath + "/neovim.lua")
    then builtins.readFile (luaPath + "/neovim.lua")
    else "";

in

pkgs.wrapNeovim pkgs.neovim-unwrapped {
  configure = {
    packages.myPlugins.start = basePlugins ++ plugins;

    customRC = ''
      set number
      set clipboard=unnamedplus

      " Load Lua config
      lua << EOF
      ${extraLua}
      EOF

      " Load coc settings
      let g:coc_config_home = stdpath('config')
    '';
  };

  # extraMakeWrapperArgs = [
  #   # "--set"
  #   # "XDG_CONFIG_HOME"
  #   # (pkgs.runCommand "nvim-config" { } ''
  #   #   mkdir -p $out/nvim
  #   #   cp ${cocJson} $out/nvim/coc-settings.json
  #   # '')
  # ];
}
