.DEFAULT_GOAL := switch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

# Default values
max_jobs ?= auto

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

rollback:
	git checkout $(shell git rev-list -n 2 HEAD -- flake.lock | tail -n 1) -- flake.lock

switch:
	$(switch_command) switch \
		--option substitute true \
		--option download-buffer-size 10000000000 \
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

disk:
	@echo "Building SD card image for $(name)..."
	export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
	nix build \
		--option substitute true \
		--option download-buffer-size 10000000000 \
		--max-jobs $(max_jobs) \
		--keep-going \
		--system aarch64-linux \
		--impure \
		.#nixosConfigurations.$(name).config.system.build.sdImage
	@echo "SD card image built successfully!"
	@echo "Image location: $$(readlink -f result)/sd-image/*.img"
