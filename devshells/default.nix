inputs@{ pkgs, ... }:
let
  dir = builtins.readDir ../devshells;
  names = builtins.attrNames dir;
  templates = builtins.filter (f: dir.${f} == "directory") names;

  pairs = map
    (t: {
      name = t;
      value = pkgs.mkShell ((import ./${t}) inputs);
    })
    templates;
in
builtins.listToAttrs pairs
