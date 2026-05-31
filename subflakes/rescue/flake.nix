{
  description = "rescue";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "rescue";

    devshells =
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
  };
}
