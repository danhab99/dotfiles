{ ... }:

{
  imports = [
    ./modules/droid.nix
  ];

  packages.droid.enable = true;

  modules = {
    fzf.enable = true;
    git.enable = true;
    gnupg.enable = true;
    neovim.enable = true;
    nix.enable = true;
    ranger.enable = true;
    secrets.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
  };
}
