.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

flake:
	nix flake update
	$(MAKE) switch

hard-nix:
	sudo nixos-rebuild switch --max-jobs 1 --flake .#$(name)

nix:
	sudo nixos-rebuild switch --flake .#$(name)

switch: nix
	i3-msg restart
	gpgconf --kill gpg-agent
	gpgconf --launch gpg-agent

clean:
	sudo nix-collect-garbage --delete-older-than 10d

android:
	nix-on-droid switch --max-jobs 1 --flake .#default
