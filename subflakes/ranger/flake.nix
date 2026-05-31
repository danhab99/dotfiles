{
  description = "ranger";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "ranger";

    output = { pkgs, ... }: {
      homeManager = {
        home.file = {
          ".config/ranger" = {
            source = ./config;
            recursive = true;
          };
        };

        programs.zsh.initContent = builtins.readFile ./zsh.sh;
      };

    };
  };
}
