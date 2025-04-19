# NixOS config

## Creating a new machine

1. Copy hardware-configuration.nix to the correct machine

2. Set this machines name in `.env` as 

```
name=...
```

3. Run `make`

## Creating a module

```
cd ./modules
./mkModule.sh name
```
