{
  description = "Dotfiles root flake";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;

      subflakeEntries = builtins.readDir ./subflakes;
      subflakeNames = builtins.filter (
        name:
        subflakeEntries.${name} == "directory"
        && builtins.pathExists (./subflakes + "/${name}/flake.nix")
        && builtins.hasAttr name inputs
      ) (builtins.attrNames subflakeEntries);

      hasPublishedOutput = name:
        let
          flakeFile = ./subflakes + "/${name}/flake.nix";
          flakeText = builtins.readFile flakeFile;
          publishesDevshells = lib.hasInfix "devshells" flakeText;
          publishesTemplate = lib.hasInfix "template" flakeText;
        in
        publishesDevshells || publishesTemplate;

      outputSubflakes = builtins.filter (
        name: hasPublishedOutput name
      ) subflakeNames;

      # Merge a single output attr (devShells/templates) from every subflake input.
      collectOutput = outputName:
        builtins.foldl' (
          acc: name:
          let
            input = inputs.${name};
          in
          lib.recursiveUpdate acc (
            if builtins.hasAttr outputName input then builtins.getAttr outputName input else { }
          )
        ) { } outputSubflakes;
    in
    {
      devShells = collectOutput "devShells";
      templates = collectOutput "templates";
    };
}
