import ../module.nix
{
  name = "stylix";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/onedark.yaml";
        polarity = "dark";


        fonts = {
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };

          sansSerif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans";
          };

          monospace = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Sans Mono";
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };

        autoEnable = false;
      };
    };
  };
}
