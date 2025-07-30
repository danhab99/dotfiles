import ../module.nix {
  name = "threedtools";

  output = { pkgs, ... }:
    let
      # bambu-studio = pkgs.bambu-studio.overrideAttrs (oldAttrs: {
      #   version = "01.00.01.50";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "bambulab";
      #     repo = "BambuStudio";
      #     rev = "v01.00.01.50";
      #     hash = "sha256-7mkrPl2CQSfc1lRjl1ilwxdYcK5iRU//QGKmdCicK30=";
      #   };
      # });
    in
    {
      packages = [
        pkgs.freecad
        pkgs.blender
        pkgs.bambu-studio
      ];
    };
}
