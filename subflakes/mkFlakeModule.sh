#!/usr/bin/env bash

# Create a new modular subflake for a NixOS module
# Usage: ./mkFlakeModule.sh <module-name>
# Example: ./mkFlakeModule.sh git

if [ -z "$1" ]; then
  echo "Usage: $0 <module-name>"
  echo ""
  echo "Creates a new module subflake in subflakes/<module-name>/"
  echo ""
  echo "Example:"
  echo "  $0 git"
  echo ""
  echo "This will create:"
  echo "  subflakes/git/flake.nix"
  echo "  subflakes/git/.gitignore"
  exit 1
fi

MODULE_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MODULE_DIR="$REPO_ROOT/subflakes/$MODULE_NAME"

# Verify script location is inside the expected repo layout
if [ ! -f "$REPO_ROOT/flake.nix" ] || [ ! -d "$REPO_ROOT/subflakes" ]; then
  echo "Error: Could not find repository root from script location"
  exit 1
fi

# Check if module already exists
if [ -d "$MODULE_DIR" ]; then
  echo "Error: Module subflake already exists at $MODULE_DIR"
  exit 1
fi

# Create the directory
mkdir -p "$MODULE_DIR"

# Generate flake.nix with template
cat > "$MODULE_DIR/flake.nix" <<'FLAKEOF'
{
  description = "MODULE_NAME NixOS module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... } @ inputs:
    let
      mkModuleSubflake = import ../../_helpers.nix;
    in
    mkModuleSubflake {
      name = "MODULE_NAME";
      inherit inputs;
      
      options = { lib }:
        with lib;
        {
          enable = lib.mkEnableOption "MODULE_NAME module";
          # Add module-specific options here
        };

      output = { pkgs, config, cfg, lib, ... }:
        {
          packages = with pkgs; [
            # Package list for this module
          ];

          nixos = {
            # NixOS module configuration here
          };

          homeManager = {
            # Home Manager configuration here
          };
        };
    };
}
FLAKEOF

# Replace MODULE_NAME placeholder with actual name
sed -i "s/MODULE_NAME/$MODULE_NAME/g" "$MODULE_DIR/flake.nix"

# Create .gitignore
cat > "$MODULE_DIR/.gitignore" <<'GITIGNOREOF'
flake.lock
GITIGNOREOF

echo "✓ Module subflake created at $MODULE_DIR/flake.nix"
echo ""
echo "Next steps:"
echo "1. Edit $MODULE_DIR/flake.nix to add module-specific inputs if needed"
echo "2. Fill in the 'options' section with your configuration options"
echo "3. Implement 'output' sections (nixos, homeManager, packages)"
echo ""
echo "To test the module:"
echo "  nix flake show $MODULE_DIR"
