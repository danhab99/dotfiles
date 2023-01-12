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
alias vfz='gvim -v $(fzf)'


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
alias vbashrc='gvim -v ~/.bashrc'
alias vrc="gvim -v ~/.vimrc"

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
alias gpl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias gc="git commit --verbose"
alias gcf="git commit -m 'fix'"
alias gca="git commit --amend"
alias gp="git push --all"
alias gs="git status"
alias gwt="git worktree list"
alias gpt='git push origin $(git rev-parse --abbrev-ref HEAD)'
alias gco='git checkout --ignore-other-worktrees'
alias gsc="git submodule sync --recursive; git submodule update --init --recursive"
alias gf="git fetch-all"
alias cg='cd $(git root)'
alias grc="git rebase --continue"
alias vg="vim +':Git mergetool'"
alias gus="git restore --staged -- "
gcop() {
  git checkout refs/pull/$1/head
}
gn() {
  git checkout -b dan/$1
}
alias gnl="git nicelog"


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
alias capcpu="sudo cpulimit --limit 1200 -iz -p $(ps -eo %cpu,pid --sort -%cpu | head -n2 | tail -n1 | awk '{{print $2}}')"
alias capProc="sudo cpulimit --limit 1200 -iz -p "
alias r=". ranger"

alias clip="xclip -selection c"
alias upgrade-dashboard="kubectl rollout restart -n default deployment lime-dashboard"
alias screen-normal="source ~/.screenlayout/normal.sh"
alias screen-lime="source ~/.screenlayout/lime.sh"
alias cfzf=' cd $(find . -type d -print | fzf) '
alias tf="terraform"
