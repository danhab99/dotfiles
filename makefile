.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif


flake:
	nix flake update
	$(MAKE) switch

nix:
	sudo nixos-rebuild switch --flake .#$(name)

switch: nix
	i3-msg restart
	gpgconf --kill gpg-agent
	gpgconf --launch gpg-agent

setup:
	cp /etc/nixos/hardware-configuration.nix ./machine/$(name)/
	nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
	nix-channel --update
	nix-shell '<home-manager>' -A install
	$(MAKE) switch

clean:
	sudo nix-collect-garbage --delete-older-than 20d
