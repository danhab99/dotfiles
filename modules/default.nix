{ ... }:

{
  home.stateVersion = "24.05";
  imports = [
    ./appimage
    ./git
    ./gnupg
    ./i3
    ./ollama
    ./packages
    ./picom
    ./rofi
    ./urxvt
    ./vim
    ./xorg
    ./zoxide
    ./zsh
    ./fzf
  ];
}
