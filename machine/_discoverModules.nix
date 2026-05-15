# Discovers all available module subflakes by scanning subflakes/modules/
# Returns an attrset: { git = ../subflakes/modules/git; docker = ../subflakes/modules/docker; ... }

let
  subflakesDir = ../subflakes/modules;
  
  # List all directories in subflakes/modules/
  moduleNames = builtins.attrNames (builtins.readDir subflakesDir);
  
  # Filter to only directories (not files)
  moduleDirs = builtins.filter (name:
    (builtins.readDir subflakesDir).${name} == "directory"
  ) moduleNames;
  
  # Convert to path map
  modules = builtins.listToAttrs (
    builtins.map (name: {
      inherit name;
      value = subflakesDir + "/${name}";
    }) moduleDirs
  );
in
modules
