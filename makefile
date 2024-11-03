.DEFAULT_GOAL := switch

flake:
	nix flake update
	$(MAKE) switch

nix:
	sudo nixos-rebuild switch --flake .#workstation

home:
	home-manager switch --flake .#dan@workstation

switch: nix home

setup:
	cp /etc/nixos/hardware-configuration.nix .
	$(MAKE) switch-nix
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	$(MAKE) switch-home

clean:
	nix-collect-garbage --delete-older-than 30d
