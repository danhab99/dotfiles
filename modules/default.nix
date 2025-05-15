{ ... }:

{
  imports =
    let
      dir = builtins.readDir ../modules;
      names = builtins.attrNames dir;
      templates = builtins.filter (f: dir.${f} == "directory") names;
    in
    map (t: ./${t}) templates;
}
