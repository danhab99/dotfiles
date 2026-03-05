import ../module.nix {
  name = "nixos-packages";

  output =
    { pkgs, dotnet_8_nixpkgs, ... }:
    let
      d8p = import dotnet_8_nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      packages = with pkgs; [
        aider-chat-full
        audacity
        d8p.brave
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
