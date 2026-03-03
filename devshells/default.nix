inputs@{ pkgs, lib, ... }:
let
  dir = builtins.readDir ../devshells;
  names = builtins.attrNames dir;
  templates = builtins.filter (f: dir.${f} == "directory") names;

  # For each template, get the shells attrset and prefix keys with template name
  shellSets = map
    (
      t:
      let
        shells = (import ./${t}) inputs;
      in
      lib.attrsets.mapAttrs'
        (version: { shell, ... }: {
          name = if version == "" then t else "${t}-${version}";
          value = shell;
        })
        shells
    )
    templates;

  templateSets = map
    (
      t:
      let
        shells = (import ./${t}) inputs;
      in
      lib.attrsets.mapAttrs'
        (version: { template, ... }: {
          name = if version == "" then t else "${t}-${version}";
          value = template;
        })
        shells
    )
    templates;

  fold = builtins.foldl' (acc: set: acc // set) { };
in
{
  shells = fold shellSets;
  templates = fold templateSets;
}
