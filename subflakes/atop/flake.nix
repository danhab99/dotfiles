{
  description = "atop";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "atop";

    output = { pkgs, ... }: {
      packages = with pkgs; [

      ];

      nixos = { 
        programs.atop.enable = true;
      };
    };
  };
}
