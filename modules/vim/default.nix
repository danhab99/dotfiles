import ../module.nix {
  name = "vim";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [ vim-full ];

      nixos = { };

      homeManager = {
        home.sessionVariables = {
          EDITOR = pkgs.vim-full + "/bin/vim";
        };

        home.file = {
          ".vim/desert256.vim" = {
            source = builtins.fetchurl {
              url = "http://hans.fugal.net/vim/colors/desert.vim";
              sha256 = "0f6f2754ed4b49104f2c73e69c022d66c860fd675a866589fe471bcfca87ba1e";
            };
          };

          ".vimrc" = {
            source = ./vimrc;
          };
        };
      };
    };
}
