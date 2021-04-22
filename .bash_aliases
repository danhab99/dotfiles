#alias fuck='sudo $(history -p \!\!)'
#eval $(thefuck --alias)

alias cdh="cd ~"
alias ci3="cd ~/.config/i3"
alias browse="nautilus --browser . &"
alias vi="vim -v"
alias vim="vim -v"
alias v="vim -v"
alias vi3="vim -v ~/.config/i3/config"
alias valias="vim -v ~/.bash_aliases"
alias l="ls"
alias inspireme="fortune | cowsay | lolcat"
alias git-fix="git submodule sync --recursive; git submodule update --init --recursive"
alias src="source ~/.bashrc"
# Stop all containers
dstop() { docker stop $(docker ps -a -q); }

alias dockerNuke="dstop"

alias gf="git submodule sync --recursive; git submodule update --init --recursive"
alias e="electron ."

alias salias='source ~/.bash_aliases'
alias vrc='vi ~/.bashrc'

alias please='sudo'
fmkcd() { mkdir -p "$1" && cd "$1"; }
alias mkcd='fmkcd'
alias here='i3-sensible-terminal'
alias untar='tar -xf'

alias mcconsole="ssh mcserver@69.164.214.170 ./mcserver console"

alias nload="nload -u H enp2s0"
alias edit-macros="code ~/.config/macro-app/config.json"
alias fixmouse="sudo systemctl restart g600.service && i3-msg restart"

alias iosinstall="ideviceinstaller -i"
alias gai="git add -ip"
alias gpl="git pull origin master"

alias listpaths="echo $PATH | sed \"s/:/\n/g\""

alias code="code-insiders"
alias licenses="license-report --output=html | hcat"
