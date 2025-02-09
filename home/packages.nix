{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # clipit
    aichat
    archivemount
    argc
    bambu-studio
    bat
    betterlockscreen
    blender
    brave
    curl
    dbeaver-bin
    dive
    doppler
    entr
    eza
    ffmpeg
    flameshot
    fzf
    gh
    gimp
    glances
    htop-vim
    iftop
    iotop
    jq
    lazydocker
    ncdu
    neofetch
    ngrok
    nmap
    nnn
    obs-studio
    obsidian
    oneko
    playerctl
    python312Packages.pip
    railway
    ranger
    rclone
    retry
    ripgrep
    rsync
    s3cmd
    scdl
    screen
    scrot
    seahorse
    steam
    vim-full
    vlc
    vscode
    webcamoid
    yt-dlp
  ];
}
