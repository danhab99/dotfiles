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

function ranger-cd {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command
        ranger
        --cmd="map q chain shell echo %d > "$tempfile"; quitall"
    )

    ${ranger_cmd[@]} "$@"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}

function ns() {
    pwd > /tmp/nixshell
    echo $1 >> /tmp/nixshell
    nix develop .#$1
}

function notes() {
  notes_path=~/Documents/notes
  mkdir -p "$notes_path"
  note_dir="$notes_path/$(basename "$(dirname "$PWD")")/$(basename "$PWD")"
  note_path="$note_dir/$(date +"%Y-%m-%d")"
  templates_path="$notes_path/templates"

  case $1 in
    ls)
      echo "Notes in $note_dir"
      ls -lth "$note_dir"
      ;;
    prev)
      for file in "$note_dir"/*; do
        if [[ -f "$file" ]]; then
          bat -r :4 "$file"
          echo
        fi
      done
      ;;
    template)
      if [[ -z "$2" ]]; then
        echo "Available templates:"
        ls -1 "$templates_path" 2>/dev/null || echo "No templates found."
      else
        template_file="$templates_path/$2.md"
        if [[ -f "$template_file" ]]; then
          mkdir -p "$note_dir"
          cp "$template_file" "$note_path.md"
          vim "$note_path.md"
        else
          echo "Template '$2' not found in $templates_path"
        fi
      fi
      ;;
    *)
      mkdir -p "$note_dir"
      if [ -n "$1" ]; then
        vim "$note_path--$1.md"
      else
        vim "$note_path.md"
      fi
      ;;
  esac

  git -C $notes_path add $notes_path
  git -C $notes_path commit -m "$(date)" $notes_path
}

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
  nix develop $flake_path#$shell_name
fi

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
