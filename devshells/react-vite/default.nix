{ pkgs, lib, ... } : {
  name = "react-vite";

  buildInputs = with pkgs; [
    nodejs_20
    yarn
    electron
    nodePackages.prettier
    nss
    libpng
    mesa
    atkmm
    at-spi2-atk
    gtk3
    xorg.libXt
    websocat
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
    yarn
    electron
    nss
    libpng
    mesa
    atkmm
    at-spi2-atk
    gtk3
    xorg.libXt
  ]);

  ELECTRON_ENABLE_LOGGING=true;
  NODE_OPTIONS="--no-warnings --max-old-space-size=2048";
  DEBUG="electron:*";
  VITE_ENVIRONMENT_NAME="dev";

  shellHook = ''
  '';
}
