import ../module.nix
{
  name = "bitwarden";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      bitwarden-desktop
    ];

    homeManager = {
      programs.rbw = {
        enable = true;
        settings = {
          email = "dan.habot@gmail.com";
          pinentry = pkgs.pinentry-curses;
          base_url = null;
          identity_url = null;
        };
      };
    };

    nixos = { };
  };
}
