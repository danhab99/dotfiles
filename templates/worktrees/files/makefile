.DEFAULT_GOAL := fetch

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

current_dir = $(shell pwd)

plant:
	echo "Planting $(name) in $(current_dir)/$(name)"
	git -C .repo worktree add $(current_dir)/$(name) $(branch:$name)

uproot:
	git -C .repo worktree remove --force $(current_dir)/$(name)

fetch:
	git -C .repo fetch --all

ifneq ("$(branch)", "")
	branch := "main"
endif

init:
	rm -rf .repo
	git clone --bare $(repo) .repo
	echo $(branch)
	$(MAKE) plant name=main

