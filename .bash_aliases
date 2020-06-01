#alias fuck='sudo $(history -p \!\!)'
#eval $(thefuck --alias)

alias cdh="cd ~"
alias ci3="cd ~/.config/i3"
alias browse="nautilus --browser . &"
alias v="vi"
alias vi3="vi ~/.config/i3/config"
alias valias="vi ~/.bash_aliases"
alias l="ls"
alias inspireme="fortune | cowsay | lolcat"
alias git-fix="git submodule sync --recursive; git submodule update --init --recursive"
alias src="source ~/.bashrc"
# Stop all containers
dstop() { docker stop $(docker ps -a -q); }

alias dockerNuke="dstop"

alias gf="git submodule sync --recursive; git submodule update --init --recursive"
alias e="electron ."


alias tty0="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB0 /usr/local/tty.bond"
alias tty1="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB1 /usr/local/tty.bond"
alias tty2="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB2 /usr/local/tty.bond"
alias tty3="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB3 /usr/local/tty.bond"
alias tty4="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB4 /usr/local/tty.bond"
alias tty5="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB5 /usr/local/tty.bond"
alias tty6="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB6 /usr/local/tty.bond"
alias tty7="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB7 /usr/local/tty.bond"
alias tty8="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB8 /usr/local/tty.bond"
alias tty9="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB9 /usr/local/tty.bond"
alias tty10="sudo rm /usr/local/tty.bond;sudo ln -s /dev/ttyUSB10 /usr/local/tty.bond"

#switch to dvorak
alias aoeu='setxkbmap us'

alias salias='source ~/.bash_aliases'
alias vrc='vi ~/.bashrc'

alias please='sudo'
fmkcd() { mkdir -p "$1" && cd "$1"; }
alias mkcd='fmkcd'
alias here='i3-sensible-terminal'
alias untar='tar -xf'

alias mcconsole="ssh mcserver@69.164.214.170 ./mcserver console"

alias nload="nload -u H enp2s0"
