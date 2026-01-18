import ../devshell.nix {
  name = "rescue";

  versions =
    { pkgs, ... }:
    let
      downloadNixos = pkgs.writeShellScriptBin "download-nixos" ''
        set -euo pipefail

        iso_url="$(
          curl -sL https://nixos.org/download/ \
          | grep -o 'https://[^"]*nixos-[0-9]\+\.[0-9]\+.*-x86_64-linux\.iso' \
          | head -n1
        )"

        if [ -z "$iso_url" ]; then
          echo "Failed to locate NixOS ISO URL" >&2
          exit 1
        fi

        echo "Downloading: $iso_url"
        curl -L "$iso_url" -o ~/Downloads/nixos.iso
      '';

      writeBootDrive = pkgs.writeShellScriptBin "write-boot-drive" ''
        set -euo pipefail

        if [[ $# -ne 2 ]]; then
          echo "Usage: $0 <path-to-iso> <block-device>"
          echo "Example: $0 nixos.iso /dev/sdX"
          exit 1
        fi

        ISO="$1"
        DEV="$2"

        # --- sanity checks ---
        if [[ ! -f "$ISO" ]]; then
          echo "ERROR: ISO file not found: $ISO" >&2
          exit 1
        fi

        if [[ ! -b "$DEV" ]]; then
          echo "ERROR: Not a block device: $DEV" >&2
          exit 1
        fi

        if mount | grep -q "^$DEV"; then
          echo "ERROR: $DEV appears to be mounted. Unmount it first." >&2
          exit 1
        fi

        echo "ISO:  $ISO"
        echo "DISK: $DEV"
        lsblk "$DEV"

        echo
        read -rp "⚠️  THIS WILL ERASE ALL DATA ON $DEV. Type 'YES' to continue: " CONFIRM
        if [[ "$CONFIRM" != "YES" ]]; then
          echo "Aborted."
          exit 1
        fi

        # --- write ISO ---
        echo "Writing ISO to disk..."
        sudo dd if="$ISO" of="$DEV" bs=4M status=progress conv=fsync

        # --- flush & re-read partition table ---
        sync
        sudo blockdev --rereadpt "$DEV" || true

        echo
        echo "✅ Live boot drive created successfully."
        echo "You can now safely remove the device."
      '';

    in
    {
      "all" = {
        packages = with pkgs; [
          busybox
          curl
          git
          tmux
          wget
          zsh
          downloadNixos
          writeBootDrive
          vim
          neovim
          copilot
          smartmontools
        ];

        shellHook = ''
          ${pkgs.tmux}/bin/tmux -f /dev/null new-session -o default-shell=${pkgs.zsh}/bin/zsh
        '';
      };
    };
}
