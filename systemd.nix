{ ... }:

{
  services."backup" = {
    script = ''
      set -eu

      current_date=$(date +%s)
      mkdir -p /bucket/backup/$(date +%Y-%m-%d)

      tar -czvf /bucket/backup/$(date +%Y-%m-%d)/home.tar.gz /home &
      tar -czvf /bucket/backup/$(date +%Y-%m-%d)/nixstore.tar.gz /nix/store &
      wait

      for folder in /bucket/backup/*; do
        folder_date=$(date -r "$folder" +%s)
        days_old=$(( (current_date - folder_date) / (60*60*24) ))
        if [ "$days_old" -gt 7 ]; then
          rm -rf "$folder"
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  timers."backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      Persistent = true;
    };
  };
}
