# NixOS config

Dan's NixOS, nix-on-droid, and home-manager configuration using the [dendritic model](https://github.com/vic/import-tree) with [flake-parts](https://flake.parts).

## Using my modules in your flake

Add this flake as an input and import `flakeModules.default`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    dans-dotfiles.url = "github:danhab99/dotfiles";
  };

  outputs = inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.dans-dotfiles.flakeModules.default
      ];

      # All modules, devshells, and templates are now available.
      # Enable modules in your NixOS configuration:
      #   module.neovim.enable = true;
      #   module.zsh.enable = true;
      #   module.git.enable = true;
    };
}
```

This gives you:

| Output | Description |
|---|---|
| `flake.modules.nixos.*` | NixOS modules (enable with `module.<name>.enable = true`) |
| `flake.modules.droid.*` | nix-on-droid modules |
| `flake.modules.homeManager.*` | Standalone home-manager modules |
| `perSystem.devShells.*` | Development shells (`nix develop .#node-22`, etc.) |
| `flake.templates.*` | Project templates (`nix flake init -t .#blank`, etc.) |

### Available devshells

```
nix flake show github:danhab99/dotfiles#devShells
```

### Available templates

```
nix flake show github:danhab99/dotfiles#templates
```

---

## justfile

* `just update`: Updates the flake.lock to the latest
* `just switch`: Builds nix and applies the new version
* `just clean`: cleans the nix store

##### .env file

```env
name=..
device=nixos|droid
keep_garbage=10d
max_jobs=100
```

## Creating a new machine

1. cd to `./machine` and run `./mkMachine.sh`

2. Copy hardware-configuration.nix to the correct machine

3. Configure modules

## Creating a module

1. cd to `./modules` and run `./mkModule.sh`

2. Fillout nixos and homemanager modules

3. Git add new module

4. Enable module in machine file

## Creating a new workflow template

cd to `./modules/templates` and run `./mkTemplate.sh`. This will copy `blank` into the new workflow.

## Creating a user

1. cd to `./users` and run `./mkUser.sh`

2. Disable any of the things you want to disable

