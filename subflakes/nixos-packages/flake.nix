{
  description = "nixos-packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    dotnet_8_nixpkgs.url = "github:nixos/nixpkgs/04f1c8b4eab2d07d390015461d182dc5818f89c4";
    nixos-cli.url = "github:nix-community/nixos-cli/main";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "nixos-packages";

    output =
      { pkgs, ... }:
      {
        packages = with pkgs; [
          aider-chat-full
          audacity
          dbeaver-bin
          diff-pdf
          e2fsprogs
          gimp
          github-copilot-cli
          kubectl
          lm_sensors
          nettools
          obsidian
          postgresql
          powershell
          psmisc
          seahorse
          totp-cli
          transmission_4-gtk
          tree
          unixODBCDrivers.msodbcsql17
          vlc
          webcamoid
          websocat
        ];

        nixos = {
          programs.nixos-cli.enable = true;
        };
      };
  };
}
