.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

ifeq ($(device),nixos)
	switch_command := sudo nixos-rebuild
	clean_command := sudo nix-collect-garbage
else ifeq ($(device),droid)
	switch_command := nix-on-droid
	clean_command := nix-collect-garbage
endif

update:
	nix flake update
	$(MAKE) switch max_jobs=1

switch:
	$(switch_command) switch --max-jobs $(max_jobs) --flake .#$(name)

clean:
	$(clean_command) --delete-older-than $(keep_garbage)

firmware:
	fwupdmgr refresh --force
	fwupdmgr get-updates
	fwupdmgr update
