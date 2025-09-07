.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

ifeq ($(device),nixos)
	switch_command = "sudo nixos-rebuild"
else ifeq ($(device),droid)
	switch_command = "nix-on-droid"
endif

update:
	nix flake update
	$(MAKE) switch max_jobs=1

switch:
	$(switch_command) switch --max-jobs $(max_jobs) --flake .#$(name)

clean:
   sudo nix-collect-garbage --delete-older-than $(keep_garbage)
