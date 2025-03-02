{ }:
let src = name: ../../config/${name};
in {
  ".config/g600" = {
    source = src "g600";
    recursive = true;
  };

  ".config/ev-cmd.toml" = { source = src "ev-cmd/ev-cmd.toml"; };
}
