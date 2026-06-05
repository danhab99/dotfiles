# NixOS config

Dan's NixOS, nix-on-droid, and home-manager configuration using the subflake model.

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

### Available devshells

```
nix flake show github:danhab99/dotfiles#devShells
```

### Available templates

```
nix flake show github:danhab99/dotfiles#templates
```

---

## Importing subflakes into your configuration

Each subflake in `./subflakes/` is a self-contained flake that exposes one or more of:

| Type | Output | Usage |
|---|---|---|
| **Module** | `nixosModules.subflake` / `homeManagerModules.subflake` | Enable with `module.<name>.enable = true` |
| **Devshell** | `devShells.*` | Run with `nix develop .#<name>` |
| **Template** | `templates.*` | Init with `nix flake init -t .#<name>` |

### Adding a subflake to a machine

1. Add the subflake as a path input in your machine's `flake.nix`:

```nix
inputs = {
  # ... other inputs ...
  git.url = "github:danhab99/dotfiles?dir=subflakes/git";
  audio.url = "github:danhab99/dotfiles?dir=subflakes/audio";
};
```

2. Enable the module in `hostCfg.module`:

```nix
hostCfg = {
  module = {
    git = {
      enable = true;
      signingKey = "0x...";
      email = "you@example.com";
    };
    audio = {
      enable = true;
      enableBluetooth = true;
    };
  };
};
```

The `output.nix` builder automatically collects all `nixosModules.subflake` from your inputs using `get.nix`, so no extra imports are needed.

### How subflakes work

Each subflake uses `../output.nix` as a unified wrapper. It supports three modes determined by which argument you pass:

**Module mode** — provides NixOS and home-manager config:
```nix
outputs = inputs: import ../output.nix inputs {
  name = "my-module";

  options = { lib }: {
    myOption = lib.mkOption { type = lib.types.str; };
  };

  output = { pkgs, cfg, ... }: {
    packages = [ pkgs.hello ];
    nixos = { services.foo.enable = true; };
    homeManager = { programs.bash.enable = true; };
  };
};
```

**Devshell mode** — provides development shells:
```nix
outputs = inputs: import ../output.nix inputs {
  name = "go";

  devshells = { pkgs, ... }: {
    "" = { packages = [ pkgs.go pkgs.gopls ]; };
    "1.21" = { packages = [ pkgs.go_1_21 ]; };
  };
};
```

**Template mode** — provides project templates:
```nix
outputs = inputs: import ../output.nix inputs {
  name = "blank";
  description = "blank project";
  template = ./_files;
};
```

### Available subflakes

Run the following to see what's available:

```bash
# List all modules, devshells, and templates
nix flake show

# Or browse the directory
ls subflakes/
```

---

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

