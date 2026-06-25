# Default recipe
default: switch

# Load .env
set dotenv-load := true
set dotenv-override := true

name := env_var_or_default("name", "workstation")
device := env_var_or_default("device", "nixos")
keep_garbage := env_var_or_default("keep", "10d")
switch_command := if device == "nixos" { "sudo nixos-rebuild" } else { "nix-on-droid" }
clean_command  := if device == "nixos" { "sudo nix-collect-garbage" } else { "nix-collect-garbage" }

update:
    nix flake update --flake ./modules
    nix flake update --flake ./machine/{{name}}
    just switch

update-modules:
    nix flake update --flake ./modules
    for machine in laptop tradezero uconsole workstation; do nix flake update --flake ./machine/$machine; done

rollback:
    git checkout $(git rev-list -n 2 HEAD -- ./machine/{{name}}/flake.lock | tail -n 1) -- ./machine/{{name}}/flake.lock

switch:
    -rm /home/dan/.openclaw/openclaw.json.hm-backup

    {{switch_command}} switch \
        --keep-going \
        --flake ./machine/{{name}}#subflake

    -sudo systemctl restart wg-quick-wg0
    -i3-msg restart
    -sudo udevadm control --reload
    -sudo udevadm trigger
    # -sudo systemctl restart n8n.service &

clean:
    {{clean_command}} --delete-older-than {{keep_garbage}}

firmware:
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

build-image machine:
    nix build ./machine/{{machine}}#nixosConfigurations.subflake.config.system.build.images.sd-card \
        --keep-going

write device machine: (build-image machine)
    sudo dd status=progress conv=fsync \
      if=$(ls ./result/iso/nixos-*-linux.iso) \
      of=/dev/{{device}}
    sync
    sudo eject /dev/{{device}}

list-build machine:
    nix eval --json ./machine/{{machine}}#nixosConfigurations.subflake.config.system.build.images --apply builtins.attrNames

build machine variant:
    nix build --show-trace ./machine/{{machine}}#nixosConfigurations.subflake.config.system.build.images.{{variant}}

vulcheck:
    nix-shell -p vulnix --run "vulnix --system -w https://raw.githubusercontent.com/NixOS/nixpkgs/master/nixos/modules/services/security/vulnix-whitelist.toml" 2>&1 | tee vulcheck_$(date +%Y-%m-%d)

overwrite:
    find . -name "flake.lock" -not -path "./flake.lock" -exec cp ./flake.lock {} \;
    find . -name "flake.lock" -not -path "./flake.lock" -exec sh -c "cd $(dirname {}) && nix flake show" \;

fix:
    nix-store --verifu --fix-broken --repair

list:
    ./listinputs.sh | xclip -selection c
