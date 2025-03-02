{ ... }:

{
  imports = [ ./user.nix ];

  home.file = {
    ".config/g600" = {
      source = ./g600;
      recursive = true;
    };

    ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
  };
}
