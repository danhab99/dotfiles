.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

ifeq ($(device),nixos)
	switch_command := sudo nixos-rebuild
	clean_command := sudo nix-collect-garbage
	clean_command := sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
else ifeq ($(device),droid)
	switch_command := nix-on-droid
	clean_command := nix-collect-garbage
endif

update:
	nix flake update
	$(MAKE) switch max_jobs=1

rollback:
	git checkout $(shell git rev-list -n 2 HEAD -- flake.lock | tail -n 1) -- flake.lock

switch:
	$(switch_command) switch \
		--option substitute true \
		--option download-buffer-size 10000 \
		--max-jobs $(max_jobs) \
		--keep-going \
		--flake .#$(name)
	
	-i3-msg restart
	-sudo udevadm control --reload
	-sudo udevadm trigger

clean:
	$(clean_command) --delete-older-than $(keep_garbage)

firmware:
	fwupdmgr refresh --force
	fwupdmgr get-updates
	fwupdmgr update
