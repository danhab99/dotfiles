# NixOS config

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

cd to `./templates` and run `./mkTemplate.sh`. This will copy `blank` into the new workflow.

## Creating a user

1. cd to `./users` and run `./mkUser.sh`

2. Disable any of the things you want to disable

