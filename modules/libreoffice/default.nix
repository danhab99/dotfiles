import ../module.nix {
  name = "libreoffice";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        libreoffice-qt
        hunspell
        hunspellDicts.uk_UA
        hunspellDicts.th_TH
      ];

      homeManager = {

      };

      nixos = {

      };
    };
}
