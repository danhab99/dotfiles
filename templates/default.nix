let
  dir = builtins.readDir ../templates;
  names = builtins.attrNames dir;
  templates = builtins.filter (f: dir.${f} == "directory") names;

  pairs = map (t: {
    name = t;
    value = import ./${t};
  }) templates;
in
  builtins.listToAttrs pairs
