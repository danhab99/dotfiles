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
    pwd > /tmp/nixshell
    echo $1 >> /tmp/nixshell
    nix develop .#$1
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
