{ pkgs, ... }:

{
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

    path = with pkgs; [
      gnutar
      gzip
      findutils
    ];
  };

  timers."backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
    };
  };
}
