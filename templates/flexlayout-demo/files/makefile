.DEFAULT_GOAL := dev

ifneq ("$(wildcard .env)","")
  include .env
  export
endif

install:
	npm install

dev:
	npm run dev

build:
	npm run build

preview:
	npm run preview

clean:
	rm -rf node_modules dist .vite

.PHONY: install dev build preview clean
