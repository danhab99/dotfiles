
nix build \
  github:nixos-uconsole/nixos-uconsole#nixosConfigurations.uconsole-cm4-minimal.config.system.build.sdImage

sudo dd if=result/sd-image/*.img of=/dev/$1 bs=4M status=progress
sync
