.DEFAULT_GOAL := switch

flake:
	nix flake update
	$(MAKE) switch

nix:
	sudo nixos-rebuild switch --flake .$(cat name)

switch: nix

setup:
	cp /etc/nixos/hardware-configuration.nix ./machine/$(cat name)/
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	$(MAKE) switch

clean:
	sudo nix-collect-garbage --delete-older-than 20d
