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
    ./neovim
    ./nix
    ./nvidia
    ./ollama
    ./packages.nix
    ./pipewire
    ./printing
    ./ranger
    ./ratbag
    ./rofi
    ./rtlsdr
    ./sddm
    ./secrets
    ./ssh
    ./steam
    ./thinkpad
    ./threedtools
    ./timezone
    ./urxvt
    ./vim
    ./xorg
    ./zoxide
    ./zsh
  ];
}
