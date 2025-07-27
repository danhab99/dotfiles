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
      timeout = "10";
    in {
      boot.kernelParams = [
        "softlockup_panic=1"
        "hardlockup_panic=1"
        "panic=${timeout}" # reboot 10 seconds after panic
        "reboot=bios"  # or reboot=acpi
      ];

      boot.kernelModules = [ "iTCO_wdt" ]; # Intel boards

      systemd.watchdog = {
        device = "/dev/watchdog"; # path to hardware watchdog
        runtimeTime = "${timeout}s"; # system should ping at least this often
        rebootTime = "${timeout}s"; # if unresponsive for this much time, reboot
        kexecTime = null; # optional: time to wait during kexec
      };
    };
  };
}
