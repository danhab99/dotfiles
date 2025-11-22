export ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
export ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE

function gn() {
    git checkout -b dan/$(date +%Y/%m/%d)/$1;
}

function work {
    echo "Saving workdir"
    pwd > /tmp/workdir
    pwd > ~/.config/.workdir
}

function restorework {
    echo "Restoring $(cat ~/.config/.workdir)"
    cp ~/.config/.workdir /tmp/workdir
}

function vacay {
    echo "Have funn"
    rm /tmp/workdir
    rm /tmp/nixshell
}

function ns() {
  local cwd=$(realpath .)
  echo "$cwd" > /tmp/nixshell
  echo "$1" >> /tmp/nixshell
  nix develop "$cwd#$1" -c zsh
}

function dev-shell() {
  shell=${1:-"blank"}
  nix flake init --template /etc/nixos#$shell
  cp /etc/nixos/flake.lock .
}

function update-betterlockscreen() {
  betterlockscreen -u "$(cat ~/.config/nitrogen/bg-saved.cfg | grep file= | cut -d '=' -f2)"
}

alias devshell="dev-shell";
alias nixshell="dev-shell";

# If not already inside tmux, start a fresh tmux session and never reattach
if [ -z "$TMUX" ]; then
  # Use a (unique) session name so it never collides
  tmux new-session -s "term-$$-$(date +%s)" \
    \; set-option -g exit-empty on \
    \; set-option -g destroy-unattached on \
    \; attach
  # Note: the `attach` is redundant since new-session attaches, but included for clarity
fi

if [ -e /tmp/workdir ]
then
  DIR=$(cat /tmp/workdir)
  echo "Working in $DIR"
  cd $DIR
fi

if [ -e /tmp/nixshell ] && [ -z "$IN_NIX_SHELL" ]
then
  echo "Restoring nix shell"
  flake_path=$(cat /tmp/nixshell | head -n 1 | tail -n 1)
  shell_name=$(cat /tmp/nixshell | head -n 2 | tail -n 1)
  nix develop path:$flake_path#$shell_name -c zsh
fi

setopt NO_BEEP
