
build:
  nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); in flake.lib.generate-main ./cmd' > main.go
  go build

versionStr := `nix eval --raw .#packages.x86_64-linux.default.version`
latestChangelog := `cd changelog && ls *.md | sort -t '-' -k 1n | tail -n 1`

version:
  git tag -F ./changelog/{{latestChangelog}} {{versionStr}}
