# Dan's Dotfiles

- OS: Manjaro Linux
- WM: i3-gaps
- Compositor: picom
- Terminal Emulator: Urxvt
- Statusbar: i3bar + i3blocks

## Script usage

I use some scripts to operate my dotfiles

### update.sh

Copies all the dotfiles from around the system to repo and push them

### install.sh

Pulls and places all config files in their place

### update-binaries.sh

Captures and saves dotfile custom build scripts from `~/Documents/install`. 

Steps to add binary:

1. Clone repo into `~/Documents/install`
2. Add a `dotfiles-build` script containing the steps to install the binary
3. Run `dotfiles-update`

### install-binaries.sh

Downloads repos and runs their respective build scripts

### update-packages.sh

Saves all packages to a list

### install-packages.sh

Installs all packages at their version
