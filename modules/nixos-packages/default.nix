import ../_module.nix {
  name = "nixos-packages";
  requires = {
    dotnet_8_nixpkgs.url = "github:nixos/nixpkgs/04f1c8b4eab2d07d390015461d182dc5818f89c4";
  };

  output =
    # { pkgs, dotnet_8_nixpkgs, nixos-cli, ... }:
    { pkgs, dotnet_8_nixpkgs, ... }:
    let
      # d8p = import dotnet_8_nixpkgs {
      #   system = "x86_64-linux";
      #   config.allowUnfree = true;
      # };
    in
    {
      packages = with pkgs; [
        aider-chat-full
        audacity
        # d8p.brave
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

      nixos = {
        programs.nixos-cli.enable = true;
      };
    };
}
