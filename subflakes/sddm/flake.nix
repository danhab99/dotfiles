{
  description = "sddm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "sddm";

    output =
      {
        pkgs,
        config,
        cfg,
        lib,
        ...
      }:
      {
        packages = with pkgs; [
          # ...
        ];

        nixos = {
          services.displayManager = {
            sddm.enable = true;
            # defaultSession = "none+i3";
          };
        };
      };
  };
}
