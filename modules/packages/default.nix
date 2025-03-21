import ../module.nix
{
  name = "packages";

  output = { pkgs, ... }:
    let
      customBusybox = pkgs.busybox.overrideAttrs (oldAttrs: rec {
        postInstall = ''
          ${oldAttrs.postInstall or ""}
          # Remove the reboot symlink if it exists
          rm -f $out/bin/reboot
          rm -f $out/bin/host*
        '';
      });
    in
    {
      packages = with pkgs; [
        # linuxKernel.packages.linux_zen.nvidia_x11
        # minio-client
        # mongodb-compass
        # mongodb-tools
        # neovim
        # ngrok
        # pamixer
        # pkgsi686Linux.gperftools
        # python312Packages.pip
        aichat
        alsa-utils
        arandr
        archivemount
        argc
        astyle
        autorandr
        base16-schemes
        bat
        betterlockscreen
        brave
        curl
        customBusybox
        dbeaver-bin
        dive
        entr
        ffmpeg
        file
        flameshot
        gimp
        glances
        gnumake
        gnutar
        gparted
        gqrx
        gzip
        htop-vim
        iftop
        iotop
        jq
        lazydocker
        lazygit
        linuxKernel.packages.linux_zen.nvidia_x11
        lm_sensors
        ncdu
        nemo
        neofetch
        nix-ld
        nmap
        nnn
        nodejs_22
        nvtopPackages.full
        obs-studio
        obsidian
        oneko
        openssl
        pamixer
        pavucontrol
        playerctl
        pulseaudioFull
        ranger
        rclone
        retry
        ripgrep
        rofi
        rsync
        s3cmd
        scdl
        screen
        scrot
        seahorse
        unzip
        usbutils
        vim-full
        vlc
        vscode
        webcamoid
        wget
        yai
        yarn
        yt-dlp
        zip

      ];

      homeManager = { };

      nixos = { };
    };
}
