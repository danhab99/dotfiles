# https://github.com/notusknot/dotfiles-nix/blob/e64745a1541d8acd0b1ed548827bd5c59d2140ac/modules/template.nix
{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.vim;

in {
  options.modules.vim = { enable = mkEnableOption "vim"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ vim-full ];

    home.sessionVariables = { EDITOR = pkgs.vim-full + "/bin/vim"; };

    home.files = {
      ".vim/desert256.vim" =
        builtins.fetchurl "http://hans.fugal.net/vim/colors/desert.vim";
      ".vimrc" = ./vimrc;
    };
  };
}
