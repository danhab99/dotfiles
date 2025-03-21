import ../module.nix {
  name = "nix";

  output = { pkgs, ... }: {

    packages = with pkgs;
      [
        nix-index
      ];

    nixos = {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      nixpkgs.config.allowUnfree = true;

      nixpkgs.config.allowBroken = true;

      # services.nixos-cli = { enable = true; };

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [ gtk3 glibc swt freetype ];

      environment.variables = with pkgs; {
        LD_LIBRARY_PATH = "${swt}/lib:$LD_LIBRARY_PATH";
      };
    };

    homeManager = { };
  };
}
