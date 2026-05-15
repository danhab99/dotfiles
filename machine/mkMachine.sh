#!/usr/bin/env bash

# Generate a new machine subflake
# Usage: ./mkMachine.sh <machine-name> [system]
# Example: ./mkMachine.sh workstation x86_64-linux

if [ -z "$1" ]; then
  echo "Usage: $0 <machine-name> [system]"
  echo "  system defaults to x86_64-linux"
  exit 1
fi

MACHINE_NAME="$1"
SYSTEM="${2:-x86_64-linux}"
MACHINE_DIR="$MACHINE_NAME"

if [ ! -f "_helpers.nix" ]; then
  echo "Error: Run this script from the machine/ directory"
  exit 1
fi

mkdir -p "$MACHINE_DIR"

# Build the module list inline by scanning subflakes/modules/
MODULE_LINES=""
for dir in ../subflakes/modules/*/; do
  name=$(basename "$dir")
  MODULE_LINES="${MODULE_LINES}          ${name}.enable = false;\n"
done

# Build the user list inline by scanning users/
USER_LINES=""
for dir in ../users/*/; do
  name=$(basename "$dir")
  USER_LINES="${USER_LINES}          ${name}.enable = true;\n"
done

# Generate flake.nix with hostConfig inlined
cat > "$MACHINE_DIR/flake.nix" <<FLAKE
{
  description = "${MACHINE_NAME} NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    openclaw.url = "github:openclaw/nix-openclaw";
    nur.url = "github:nix-community/NUR";
    adirofi.url = "github:danhab99/rofi";
  } // (import ../_scanModules.nix).inputs;

  outputs = { self, nixpkgs, home-manager, nixos-hardware, openclaw, nur, adirofi, ... } @ inputs:

    let
      system = "${SYSTEM}";

      hostConfig = {
        hostName = "${MACHINE_NAME}";
        inherit system;

        users = {
$(printf "%s" "$USER_LINES")
        };

        module = {
$(printf "%s" "$MODULE_LINES")
        };
      };

      scannedModules = import ../_scanModules.nix;
      modulesDir = ../subflakes/modules;
      moduleDirs = scannedModules.moduleDirs;

      enabledModuleNames = builtins.filter (name:
        hostConfig.module.\${name}.enable or false
      ) (builtins.attrNames hostConfig.module);

      loadModuleFlake = moduleName:
        let
          modulePath = modulesDir + "/\${moduleName}";
          moduleFlakeFile = import "\${modulePath}/flake.nix";
          moduleInputs = {
            self = { };
            nixpkgs = inputs.nixpkgs;
            home-manager = inputs.home-manager;
            flake-utils = inputs.nixpkgs;
          };
        in
        moduleFlakeFile.outputs moduleInputs;

      enabledModuleInputs = builtins.listToAttrs (
        builtins.map (moduleName: {
          inherit moduleName;
          value = loadModuleFlake moduleName;
        }) enabledModuleNames
      );

      mkMachineFlake = import ../_helpers.nix;
    in
    mkMachineFlake {
      name = "${MACHINE_NAME}";
      inherit system enabledModuleInputs hostConfig inputs;
      hardwareConfigPath = ./hardware-configuration.nix;
      outputFn = null;
    };
}
FLAKE

echo "Machine flake generated at $MACHINE_DIR/flake.nix"
echo ""
echo "Next steps:"
echo "1. Edit $MACHINE_DIR/flake.nix to enable modules and set options in hostConfig"
echo "2. Add hardware-configuration.nix (copy from nixos-generate-config output)"
