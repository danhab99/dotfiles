{ pkgs, ... }:

{
  services."backup" = {
    script = ''
      set -eu

      mkdir -p /bucket/backup/$(date +%Y-%m-%d)

      function backup() {
        ${pkgs.gnutar}/bin/tar -cz \
        --exclude-caches \
        --exclude="**/node_modules" \
        --exclude="**/*[Cc]ache*" \
        -f /bucket/backup/$1.$(date +%Y-%m-%d).tar.gz $2
      }

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
