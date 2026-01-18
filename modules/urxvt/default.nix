import ../module.nix {
  name = "urxvt";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [ rxvt-unicode ];

      nixos = { };

      homeManager = {
        programs.urxvt = {
          enable = true;

          scroll.bar.enable = false;
        };

        home.file = {
          ".urxvt/ext" = {
            source = builtins.fetchGit {
              shallow = true;
              url = "https://github.com/simmel/urxvt-resize-font.git";
              rev = "b5935806f159594f516da9b4c88bf1f3e5225cfd";
            };
            recursive = true;
          };
        };
      };
    };
}
