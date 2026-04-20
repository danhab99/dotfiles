import ../_module.nix {
  name = "tmux";

  output =
    { pkgs
    , lib
    , config
    , ...
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
        home.sessionVariables = {
          TMUX_TMPDIR = lib.mkForce "/tmp";
        };

        programs.tmux = {
          enable = true;
          baseIndex = 1;
          clock24 = true;
          keyMode = "vi";
          newSession = false;
          prefix = "C-a";

          terminal = "$TERM";

          extraConfig = ''
            unbind-key C-b
            bind-key C-a send-prefix
            set -sg escape-time 0
            set -g xterm-keys on
            set -s set-clipboard on
            set -g pane-base-index 1
            set -g renumber-windows on

            # Set key bindings for copy mode
            setw -g mode-keys vi
            bind-key -T copy-mode-vi r send -X rectangle-toggle
            bind-key -T copy-mode-vi v send -X begin-selection
            bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "sh -c 'if command -v wl-copy >/dev/null 2>&1; then wl-copy; elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard -in; else cat >/dev/null; fi'"
            bind P paste-buffer

            # Enable mouse support
            set -g mouse on

            # Disable status bar
            set -g status off

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

            # i3-style pane and workspace navigation, using Alt as tmux's mod key.
            bind-key h select-pane -L
            bind-key j select-pane -D
            bind-key k select-pane -U
            bind-key l select-pane -R
            bind-key -n M-h select-pane -L
            bind-key -n M-j select-pane -D
            bind-key -n M-k select-pane -U
            bind-key -n M-l select-pane -R

            bind-key H swap-pane -t '{left-of}'
            bind-key J swap-pane -t '{down-of}'
            bind-key K swap-pane -t '{up-of}'
            bind-key L swap-pane -t '{right-of}'
            bind-key -n M-H swap-pane -t '{left-of}'
            bind-key -n M-J swap-pane -t '{down-of}'
            bind-key -n M-K swap-pane -t '{up-of}'
            bind-key -n M-L swap-pane -t '{right-of}'

            bind-key v split-window -h -c '#{pane_current_path}'
            bind-key V split-window -v -c '#{pane_current_path}'
            bind-key -n M-v copy-mode
            bind-key -n M-V split-window -v -c '#{pane_current_path}'
            bind-key -n M-Enter new-window -c '#{pane_current_path}'

            bind-key q kill-pane
            bind-key -n M-q kill-pane
            bind-key -n M-w choose-window
            bind-key f resize-pane -Z
            bind-key -n M-f resize-pane -Z
            bind-key Tab last-window
            bind-key -n M-Tab last-window

            bind-key r switch-client -T resize
            bind-key -n M-r switch-client -T resize
            bind-key -T resize h resize-pane -L 5
            bind-key -T resize j resize-pane -D 5
            bind-key -T resize k resize-pane -U 5
            bind-key -T resize l resize-pane -R 5
            bind-key -T resize Left resize-pane -L 5
            bind-key -T resize Down resize-pane -D 5
            bind-key -T resize Up resize-pane -U 5
            bind-key -T resize Right resize-pane -R 5
            bind-key -T resize Enter switch-client -T root
            bind-key -T resize Escape switch-client -T root
            bind-key -T resize r switch-client -T root
          '';
        };
      };
    };
}
