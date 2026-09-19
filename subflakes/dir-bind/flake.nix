{
  description = "dir-bind";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "dir-bind";

    options = { lib, ... }: with lib; {
      binds = mkOption {
        type = types.listOf (types.submodule {
          options = {
            dir = mkOption {
              type = types.str;
              description = "Directory under /home/dan to redirect, e.g. \"Pictures\".";
            };
            dest = mkOption {
              type = types.str;
              description = "Mount point owning the real directory, e.g. \"bucket\" for /bucket.";
            };
          };
        });
        default = [ ];
        description = ''
          Symlinks /home/dan/<dir> to /<dest>/<dir> via a systemd-tmpfiles
          L+ rule — for redirecting home directories onto another mounted
          drive (e.g. a spinny disk mounted at /bucket).
        '';
      };
    };

    output = { cfg, ... }:
      let
        mkBind = { dest, dir }: "L+ /home/dan/${dir} - - - - /${dest}/${dir}";
      in
      {
        nixos = {
          systemd.tmpfiles.rules = map mkBind cfg.binds;
        };
      };
  };
}
