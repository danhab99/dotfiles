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

export DIRENV_WARN_TIMEOUT=0

function ns() {
  local shell_name="${1:-default}"
  local flake_dir
  local git_root

  # Find git repository root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null)
  
  if [[ -z "$git_root" ]]; then
    echo "Not in a git repository. Use direnv manually or run from a git repo."
    return 1
  fi

  # Determine flake location
  if [[ -f "$git_root/flake.nix" ]]; then
    flake_dir="$git_root"
  else
    flake_dir="/etc/nixos"
  fi

  # Create .envrc content
  local envrc_content
  if [[ "$flake_dir" == "$git_root" ]]; then
    envrc_content="use flake .#${shell_name}"
  else
    envrc_content="use flake ${flake_dir}#${shell_name}"
  fi

  # Check if .envrc already exists with the same config
  if [[ -f "$git_root/.envrc" ]] && grep -qF "$envrc_content" "$git_root/.envrc"; then
    echo "Devshell '${shell_name}' is already configured for ${git_root}"
    direnv allow "$git_root"
    exec zsh
    return
  fi

  # Ask when ns is manually called with a different shell or for new setup
  echo "Set ${git_root} to always use devshell '${shell_name}'? (y/n)"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "$envrc_content" > "$git_root/.envrc"
    echo "Created $git_root/.envrc"
    direnv allow "$git_root"
    echo "Devshell will activate on next directory entry. Reloading now..."
    exec zsh
  else
    # One-time use without persisting
    nix develop "path:${flake_dir}#${shell_name}"
  fi
}

function template() {
  name=${1:-"blank"}
  nix flake init --template /etc/nixos#$name
  cp /etc/nixos/flake.lock .
}

function update-betterlockscreen() {
  betterlockscreen -u "$(cat ~/.config/nitrogen/bg-saved.cfg | grep file= | cut -d '=' -f2)"
}

# If not already inside tmux, start a fresh tmux session and never reattach
if [ -z "$TMUX" ]; then
  # Use a (unique) session name so it never collides
  tmux new-session -s "term-$$-$(date +%s)" \
    \; set-option -g exit-empty on \
    \; set-option -g destroy-unattached on \
    \; attach
  # Note: the `attach` is redundant since new-session attaches, but included for clarity
fi

# Initialize direnv hook - must come before any cd commands
eval "$(direnv hook zsh)"

if [ -e /tmp/workdir ]
then
  DIR=$(cat /tmp/workdir)
  echo "Working in $DIR"
  cd $DIR
fi

setopt NO_BEEP

if [ -n "$IN_NIX_SHELL" ]; then
  echo "You are inside a Nix shell."
fi

