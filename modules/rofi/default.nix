import ../module.nix {
  name = "rofi";

  output = { pkgs, lib, ... }: {
    packages = with pkgs; [ rofi ];

    # homeManager.home.file = {
    #   ".config/rofi" = let rev = "86e6875d9e89ea3cf95c450cef6497d52afceefe";
    #   in {
    #     # source = builtins.fetchGit {
    #     #   shallow = true;
    #     #   url = "https://github.com/adi1090x/rofi.git";
    #     #   inherit rev;
    #     # };
    #     source = pkgs.stdenv.mkDerivation {
    #       name = "adi1090x/rofi";
    #       version = rev;

    #       src = builtins.fetchGit {
    #         shallow = true;
    #         url = "https://github.com/adi1090x/rofi.git";
    #         inherit rev;
    #       };

    #       installPhase = ''
    #         cd $src
    #         cp -r $src $out
    #         . $out/setup.sh
    #       '';
    #     };
    #     recursive = true;
    #   };
    # };
  };
}
