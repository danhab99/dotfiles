{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "rofi";

  output = { ... }: {
    home.packages = with pkgs; [ rofi ];

    home.file = {
      ".config/rofi" = let rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
      in {
        source = builtins.fetchGit {
          shallow = true;
          url = "https://github.com/adi1090x/rofi.git";
          inherit rev;
        };
        # source = stdenv.mkDerivation {
        #   name = "adi1090x/rofi";
        #   version = rev;

        #   src = builtins.fetchGit {
        #     shallow = true;
        #     url = "https://github.com/adi1090x/rofi.git";
        #     inherit rev;
        #   };

        #   installPhase = ''
        #     cd $src
        #     chmod +x setup.sh
        #     ./setup.sh
        #     cp $src $out
        #   '';
        # };
        recursive = true;
      };
    };
  };
}
