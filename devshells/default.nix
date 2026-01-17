inputs@{ pkgs, lib, ... }:
let
  dir = builtins.readDir ../devshells;
  names = builtins.attrNames dir;
  templates = builtins.filter (f: dir.${f} == "directory") names;

  # For each template, get the shells attrset and prefix keys with template name
  shellSets = map
    (t: 
      let
        shells = (import ./${t}) inputs;
      in
        lib.attrsets.mapAttrs'
          (version: shell: {
            name = "${t}-${version}";
            value = shell;
          })
          shells
    )
    templates;
in
# Merge all shell sets into one flat attrset
builtins.foldl' (acc: set: acc // set) {} shellSets
