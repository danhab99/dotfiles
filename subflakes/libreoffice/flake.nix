{
  description = "libreoffice";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
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

        homeManager = { };

        nixos = { };
      };
  };
}
