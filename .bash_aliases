#alias fuck='sudo $(history -p \!\!)'
#eval $(thefuck --alias)

alias cdh="cd ~"
alias ci3="cd ~/.config/i3"
alias browse="nautilus --browser . &"
alias vi="gvim -v"
alias vim="gvim -v"
alias v="gvim -v"
alias vv="gvim -v ."
alias vi3="gvim -v ~/.config/i3/config"
alias valias="gvim -v ~/.bash_aliases"
alias vssh="gvim -v ~/.ssh/config"
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
alias vrc='gvim -v ~/.bashrc'

alias please='sudo'
fmkcd() { mkdir -p "$1" && cd "$1"; }
alias mkcd='fmkcd'
alias here='i3-sensible-terminal'
alias untar='tar -xf'

alias nload="nload -u H enp2s0"
alias edit-macros="code ~/.config/macro-app/config.json"
alias fixmouse="sudo systemctl restart g600.service && i3-msg restart"

alias iosinstall="ideviceinstaller -i"
alias ga="git add"
alias gaa="git add ."
alias gai="git add -ip"
alias gpl="git pull origin master"
alias gd="git diff"
alias gds="git diff --staged"
alias gc="git commit --verbose"
alias gcf="git commit -m 'fix'"
alias gca="git commit --amend"
alias gp="git push --all"
alias gs="git status"

alias listpaths="echo $PATH | sed \"s/:/\n/g\""

alias code="code-insiders"
alias licenses="license-report --output=html | hcat"
function copy() {
  cat $1 | xsel -i -b
}
alias xmerge="xrdb -merge ~/.Xresources && xrdb -merge ~/.Xdefaults"
alias dc="docker-compose"
# alias gvim -vrc="vim ~/.vimrc"
alias open="xdg-open"
alias n="nnn -Hdior"
