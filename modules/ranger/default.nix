import ../module.nix {
  name = "ranger";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        ranger
      ];

      homeManager = {
        home.file = {
          ".config/ranger" = {
            source = ./config;
            recursive = true;
          };
        };

        programs.zsh.initContent = builtins.readFile ./zsh.sh;
      };

      nixos = {

      };
    };
}
