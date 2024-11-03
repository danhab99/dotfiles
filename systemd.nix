{ pkgs, ... }:

{
  services."backup" = {
    script = ''
      set -eu

      mkdir -p /bucket/backup/$(date +%Y-%m-%d)

      ${pkgs.gnutar}/bin/tar -czvf /bucket/backup/$(date +%Y-%m-%d)/home.tar.gz /home &
      ${pkgs.gnutar}/bin/tar -czvf /bucket/backup/$(date +%Y-%m-%d)/nixstore.tar.gz /nix/store &
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
