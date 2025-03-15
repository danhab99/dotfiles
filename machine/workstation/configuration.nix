{ pkgs, ... }:

{
  imports = [ ../../parts/default.nix ];

  config.part = {
    appimage.enable = true;
    docker.enable = true;
    font.enable = true;
    gnupg.enable = true;
    i18n.enable = true;
    i3.enable = true;
    nix.enable = true;
    packages.enable = true;
    pipewire.enable = true;
    printing.enable = true;
    ratbag.enable = true;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;
    steam.enable = true;
    timezone.enable = true;
    xserver.enable = true;
    zsh.enable = true;
  };

  config = {
    users.users.dan = {
      isNormalUser = true;
      description = "dan";
      extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
      shell = pkgs.zsh;
    };

    networking = { 
      networkmanager.enable = true;
      hostName = "workstation";
    };

    environment.localBinInPath = true;

    services.dbus.enable = true;
    services.xserver.config = ''
      Section "Device"
        Identifier "GPU0"
        Driver "nvidia"
        Option "AllowFlipping" "True"
        Option "TripleBuffer" "True"
        Option "ForceFullCompositionPipeline" "True"
      EndSection

      Section "Monitor"
          Identifier "HDMI-0"
          Option "PreferredMode" "1920x1080"
      EndSection

      Section "Monitor"
          Identifier "DP-5"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "HDMI-0"
      EndSection

      Section "Monitor"
          Identifier "DP-1"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "DP-5"
      EndSection

      Section "Screen"
          Identifier "Screen0"
          Device "GPU0"
          Option "metamodes" "HDMI-0: 1920x1080 +0+0, DP-5: 1920x1080 +1920+0, DP-1: 1920x1080 +3840+0"
          Option "AllowIndirectGLXProtocol" "True"
          Option "TripleBuffer" "True"
      EndSection
    '';

    systemd = {
      tmpfiles.rules = [
        "L+ /home/dan/Videos - - - - /bucket/Videos"
        "L+ /home/dan/Pictures - - - - /bucket/Pictures"
      ];

      services."backup" = {
        script = ''
          set -eu

          function cleanup_old_backups() {
            ${pkgs.findutils}/bin/find /bucket/backup -type f -name "*.tar.gz" -mtime +7 -delete
          }

          function backup() {
            ${pkgs.gnutar}/bin/tar -cz \
            --exclude-caches \
            --exclude="**/node_modules" \
            --exclude="**/*[Cc]ache*" \
            --exclude="/home/dan/Videos" \
            --exclude="/home/dan/Pictures" \
            --seek \
            -f /bucket/backup/$1.$(date +%Y-%m-%d).tar.gz $2
          }

          cleanup_old_backups
          backup home /home/dan &

          wait
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        path = with pkgs; [ gnutar gzip findutils ];
      };

      timers."backup" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = true;
        };
      };

      services."download-music" = {
        script = "/home/dan/Music/download.sh";

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };

        path = with pkgs; [ gnutar gzip findutils ];
      };

      timers."download-music" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 02:00:00";
          Persistent = true;
        };
      };
    };
  };
}
