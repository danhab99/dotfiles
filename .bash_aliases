#alias fuck='sudo $(history -p \!\!)'
#eval $(thefuck --alias)

alias cdh="cd ~"
alias ci3="cd ~/.config/i3"
alias browse="nautilus --browser . &"
alias v="vi"
alias vi3="vi ~/.config/i3/config"
alias valias="vi ~/.bash_aliases"
alias rtool="python3 ~/Documents/olibra/remotes/rtool/rtool.py"
alias l="ls"
alias screenSnowbird="sudo screen -L /dev/ttyUSB0 57600"
alias inspireme="fortune | cowsay | lolcat"
alias git-fix="git submodule sync --recursive; git submodule update --init --recursive"

# Stop all containers
dstop() { docker stop $(docker ps -a -q); }

alias dockerNuke="dstop"
