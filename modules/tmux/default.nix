import ../_module.nix {
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
      workspaceBindings =
        let
          workspaces = [
            {
              key = "1";
              shiftKey = "!";
              target = "1";
            }
            {
              key = "2";
              shiftKey = "@";
              target = "2";
            }
            {
              key = "3";
              shiftKey = "#";
              target = "3";
            }
            {
              key = "4";
              shiftKey = "$";
              target = "4";
            }
            {
              key = "5";
              shiftKey = "%";
              target = "5";
            }
            {
              key = "6";
              shiftKey = "^";
              target = "6";
            }
            {
              key = "7";
              shiftKey = "&";
              target = "7";
            }
            {
              key = "8";
              shiftKey = "*";
              target = "8";
            }
            {
              key = "9";
              shiftKey = "(";
              target = "9";
            }
            {
              key = "0";
              shiftKey = ")";
              target = "10";
            }
          ];
        in
        lib.concatMapStringsSep "\n" (
          { key, shiftKey, target }:
          ''
            bind-key ${key} select-window -t :=${target}
            bind-key -n A-${key} select-window -t :=${target}
            bind-key ${shiftKey} swap-window -t :=${target}
            bind-key -n A-${shiftKey} swap-window -t :=${target}
          ''
        ) workspaces;
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
            set -g pane-base-index 1
            set -g renumber-windows on
            set -g status-position bottom
            set -g status-justify left

            # Set key bindings for copy mode
            setw -g mode-keys vi
            bind-key -T copy-mode-vi r send -X rectangle-toggle
            bind-key -T copy-mode-vi v send -X begin-selection
            bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -sel clip -i"
            bind P paste-buffer

            # Enable mouse support
            set -g mouse on

            # Mirror the i3 palette so tmux windows feel like workspaces.
            set -g status-style bg=#2f343f,fg=#f3f4f5
            set -g message-style bg=#2f343f,fg=#f3f4f5
            set -g message-command-style bg=#2f343f,fg=#f3f4f5
            set -g pane-border-style fg=#676E7D
            set -g pane-active-border-style fg=#f3f4f5
            setw -g window-status-format " #I "
            setw -g window-status-style bg=default,fg=#676E7D
            setw -g window-status-current-format " #I "
            setw -g window-status-current-style bg=#2f343f,fg=#f3f4f5

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
            bind-key -n A-h select-pane -L
            bind-key -n A-j select-pane -D
            bind-key -n A-k select-pane -U
            bind-key -n A-l select-pane -R

            bind-key H swap-pane -t '{left-of}'
            bind-key J swap-pane -t '{down-of}'
            bind-key K swap-pane -t '{up-of}'
            bind-key L swap-pane -t '{right-of}'
            bind-key -n A-H swap-pane -t '{left-of}'
            bind-key -n A-J swap-pane -t '{down-of}'
            bind-key -n A-K swap-pane -t '{up-of}'
            bind-key -n A-L swap-pane -t '{right-of}'

            bind-key v split-window -h -c '#{pane_current_path}'
            bind-key V split-window -v -c '#{pane_current_path}'
            bind-key -n A-v split-window -h -c '#{pane_current_path}'
            bind-key -n A-V split-window -v -c '#{pane_current_path}'
            bind-key Enter new-window -c '#{pane_current_path}'

            bind-key q kill-pane
            bind-key -n A-q kill-pane
            bind-key f resize-pane -Z
            bind-key -n A-f resize-pane -Z
            bind-key Tab last-window
            bind-key -n A-Tab last-window

            bind-key r switch-client -T resize
            bind-key -n A-r switch-client -T resize
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

            ${workspaceBindings}
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
