import ../module.nix {
  name = "tmux";

  output =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      myTmuxZsh = ''
        # If not already inside tmux, start a fresh tmux session and never reattach
        if [ -z "$TMUX" ]; then
          # Use a (unique) session name so it never collides
          tmux new-session -s "term-$$-$(date +%s)" \
            \; set-option -g exit-empty on \
            \; set-option -g destroy-unattached on \
            \; attach
          # Note: the `attach` is redundant since new-session attaches, but included for clarity
        fi
      '';
    in
    {
      packages = with pkgs; [

      ];

      homeManager = {
        programs.tmux = {
          enable = true;
          baseIndex = 1;
          clock24 = true;
          keyMode = "vi";
          newSession = false;

          terminal = "$TERM";

          extraConfig = ''
            # Set key bindings for copy mode
            setw -g mode-keys vi
            bind-key -T copy-mode-vi r send -X rectangle-toggle
            bind-key -T copy-mode-vi v send -X begin-selection
            bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -sel clip -i"
            bind P paste-buffer

            # Enable mouse support
            set -g mouse on

            # Set environment variable for DISPLAY
            set-environment -g DISPLAY :0

            # Set session cleanup options
            set-option -g detach-on-destroy on
            set-option -g exit-empty on
            set-option -g destroy-unattached on
            set -g remain-on-exit on

            # Disable automatic renaming of windows and titles
            set-option -g set-titles off
            set-option -g automatic-rename off

            set-option -g status off
          '';
        };

      };

      nixos = {
        # module.zsh.extras = ''
        #   ${config.programs.zsh.initExtra or ""}

        #   ${myTmuxZsh}
        # '';
      };
    };
}
