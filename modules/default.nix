{ ... }:

{
  # home.stateVersion = "24.05";
  imports = [
    ./appimage
    ./docker
    ./font
    ./fzf
    ./git
    ./gnupg
    ./i18n
    ./i3
    ./nix
    ./ollama
    ./packages
    ./picom
    ./pipewire
    ./printing
    ./ratbag
    ./rofi
    ./sddm
    ./secrets
    ./ssh
    ./steam
    ./threedtools
    ./timezone
    ./urxvt
    ./vim
    ./xorg
    ./zoxide
    ./zsh
  ];
}
