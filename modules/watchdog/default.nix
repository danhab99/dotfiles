import ../module.nix
{
  name = "watchdog";

  output = { pkgs, ... }: {
    homeManager = {
      programs.zsh.shellAliases = {
        panic = "echo c | sudo tee /proc/sysrq-trigger";
      };
    };

    nixos = let 
      timeout = 10;
      ts = builtins.toString;
    in {
      boot.kernelParams = [
        "efi_pstore.pstore_disable=0"
        "hardlockup_panic=1"
        "panic=${ts timeout}" # reboot 10 seconds after panic
        "reboot=bios"
        "softlockup_panic=1"
      ];

      boot.kernelModules = [ "iTCO_wdt" ]; # Intel boards

      systemd.settings.Manager = {
        KExecWatchdogSec = null;
        RebootWatchdogSec = "${ts ( timeout * 2 ) }s"; # if unresponsive for this much time, reboot
        RuntimeWatchdogSec = "${ts timeout}s"; # system should ping at least this often
        WatchdogDevice = "/dev/watchdog"; # path to hardware watchdog
      };

      boot.crashDump.enable = true;
    };
  };
}
