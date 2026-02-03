# Default recipe
default := "switch"

# Load .env
set dotenv-load := true
set dotenv-path := ".env"

name := env_var_or_default("name", "workstation")
device := env_var_or_default("device", "nixos")
keep_garbage := env_var_or_default("keep", "10d")
max_jobs := env_var_or_default("max", "100")

switch_command := if device == "nixos" { "sudo nixos-rebuild" } else { "nix-on-droid" }
clean_command  := if device == "nixos" { "sudo nix-collect-garbage" } else { "nix-collect-garbage" }

update:
    nix flake update
    just switch max_jobs=1

rollback:
    git checkout $(git rev-list -n 2 HEAD -- flake.lock | tail -n 1) -- flake.lock

switch:
    {{switch_command}} switch \
        --option substitute true \
        --option download-buffer-size 10000000000 \
        --max-jobs {{max_jobs}} \
        --keep-going \
        --flake .#{{name}}

    i3-msg restart
    sudo udevadm control --reload
    sudo udevadm trigger

clean:
    {{clean_command}} --delete-older-than {{keep_garbage}}

firmware:
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

build-image machine max_jobs:
    nix build .#nixosConfigurations.{{machine}}.config.system.build.images.sd-card \
        --keep-going \
        --option substitute true \
        --option download-buffer-size 10000000000 \
        --max-jobs {{max_jobs}}

write device machine max_jobs: (build-image machine max_jobs)
    sudo dd status=progress conv=fsync \
      if=$(ls ./result/iso/nixos-*-linux.iso) \
      of=/dev/{{device}}
    sync
    sudo eject /dev/{{device}}

dryrun machine:
    nix build .#nixosConfigurations.{{machine}}.config.system.build.toplevel
