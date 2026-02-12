import ../devshell.nix {
  name = "rescue";

  versions =
    { pkgs, ... }:
    {
      "all" = {
        packages = with pkgs; [
          busybox
          copilot
          curl
          downloadNixos
          git
          just
          neovim
          smartmontools
          tmux
          vim
          wget
          writeBootDrive
          zsh
        ];

        shellHook = ''
          ${pkgs.tmux}/bin/tmux -f /dev/null new-session -o default-shell=${pkgs.zsh}/bin/zsh
        '';
      };
    };
}
