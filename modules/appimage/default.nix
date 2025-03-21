import ../module.nix
{
  name = "appimage";

  output = { pkgs, ... }: {
    nixos = {
      environment.systemPackages = with pkgs;
        [
          # ...
        ];

      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    };

    homeManager = { };
  };
}

