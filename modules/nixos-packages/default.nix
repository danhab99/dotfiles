import ../module.nix {
  name = "nixos-packages";

  output =
    { pkgs, ... }:
    let
    in
    {
      packages = with pkgs; [
        audacity
        brave
        dbeaver-bin
        gimp
        github-copilot-cli
        kubectl
        nettools
        obsidian
        postgresql
        powershell
        seahorse
        totp-cli
        tree
        unixODBCDrivers.msodbcsql17
        vlc
        webcamoid
      ];
    };
}
