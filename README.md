# NixOS config

## Makefile

* `make update`: Updates the flake.lock to the latest
* `make switch`: Builds nix and applies the new version
* `make clean`: cleans the nix store
* `make disk name=<machine>`: Builds an SD card image for ARM-based machines (e.g., uconsole)

##### .env file

```env
name=..
device=nixos|droid
keep_garbage=10d
max_jobs=auto
```

### Building SD Card Images

For ARM-based machines like the ClockworkPi uConsole, you can build bootable SD card images:

```bash
make disk name=uconsole
```

This will:
1. Build a complete NixOS system for the target architecture (aarch64-linux)
2. Create an SD card image with proper partitioning and bootloader
3. Output the image to `result/sd-image/*.img`

To flash the image to an SD card:
```bash
sudo dd if=result/sd-image/*.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with your actual SD card device. **Warning:** This will erase all data on the target device!

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

