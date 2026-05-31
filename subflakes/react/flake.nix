{
  description = "react";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "react";

    devshells =
      { pkgs, lib, ... }:
      {
        "vite" = {
          packages = with pkgs; [
            nodejs_20
            yarn
            electron
            nss
            libpng
            mesa
            atkmm
            at-spi2-atk
            gtk3
            libXt
            websocat
          ];

          env = {
            LD_LIBRARY_PATH = lib.makeLibraryPath (
              with pkgs;
              [
                yarn
                electron
                nss
                libpng
                mesa
                atkmm
                at-spi2-atk
                gtk3
                libXt
              ]
            );

            ELECTRON_ENABLE_LOGGING = true;
            NODE_OPTIONS = "--no-warnings --max-old-space-size=2048";
            DEBUG = "electron:*";
            VITE_ENVIRONMENT_NAME = "dev";
          };
        };
      };
  };
}
