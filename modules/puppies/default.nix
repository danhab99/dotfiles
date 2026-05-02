import ../_module.nix
{
  name = "puppies";

  options = { lib }: with lib; {
    puppies = mkOption {
      type = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Regex pattern to match against input.";
            example = "error:.*";
          };

          regex = mkOption {
            type = types.str;
            description = "Regex pattern to match against input.";
            example = "error:.*";
          };

          process = mkOption {
            type = types.str;
            description = "Process or command to apply when regex matches.";
            example = "log-parser";
          };

          reaction = mkOption {
            type = types.str;
            description = "Action to take after processing.";
            example = "alert";
          };

          multiple = mkOption {
            type = types.bool;
            description = "Run the reaction every time the regex is found";
          };
        };
      };
    };
  };

  output = { pkgs, cfg, ... }: {
    nixos = {
      services.puppy = {
        enable = true;
        puppies = cfg.puppies;
      };
    };
  };
}
