set -euo pipefail

iso_url="$(
  curl -sL https://nixos.org/download/ \
  | grep -o 'https://[^\"]*nixos-[0-9]\+\.[0-9]\+.*-x86_64-linux\.iso' \
  | head -n1
)"

if [ -z "$iso_url" ]; then
  echo "Failed to locate NixOS ISO URL" >&2
  exit 1
fi

echo "Downloading: $iso_url"
curl -L "$iso_url" -o ~/Downloads/nixos.iso
