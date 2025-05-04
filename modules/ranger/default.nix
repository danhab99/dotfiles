import ../module.nix
{
  name = "ranger";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      ranger
    ];

    homeManager = {
      home.file = {
        ".config/ranger" = {
          source = ./config;
          recursive = true;
        };
      };

      programs.zsh.initContent = ''
function ranger-cd {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command
        ranger
        --cmd="map q chain shell echo %d > "$tempfile"; quitall"
    )

    $${ranger_cmd[@]} "$@"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}

      '';
    };

    nixos = {

    };
  };
}

