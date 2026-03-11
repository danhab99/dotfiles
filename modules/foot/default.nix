import ../module.nix
{
  name = "foot";

  options = { lib }: with lib;
    {
      fontSize = mkOption {
        type = types.float;
        default = 12.0;
      };
    };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "monospace:size=${builtins.toString (builtins.floor cfg.fontSize)}";
            pad = "16x16";
          };
          colors = {
            alpha = "0.85";
          };
        };
      };

      stylix.targets = {
        foot.enable = true;
      };
    };

    nixos = { };
  };
}
