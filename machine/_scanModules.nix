# Shared module discovery for machine flakes.
# Returns:
#   moduleDirs  — list of module names found in subflakes/modules/
#   inputs      — attrset suitable for merging into flake inputs
#                 e.g. { module-git = "path:..."; module-docker = "path:..."; }

let
  modulesDir = ../subflakes/modules;
  dirEntries = builtins.readDir modulesDir;
  moduleDirs = builtins.filter (name:
    dirEntries.${name} == "directory"
  ) (builtins.attrNames dirEntries);
in
{
  inherit moduleDirs;
  inputs = builtins.listToAttrs (
    builtins.map (moduleName: {
      name = "module-${moduleName}";
      value = "path:../../subflakes/modules/${moduleName}";
    }) moduleDirs
  );
}
