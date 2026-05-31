{
  description = "watchdog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "watchdog";

    output = { pkgs, ... }: {
      homeManager = {
        programs.zsh.shellAliases = {
          panic = "echo c | sudo tee /proc/sysrq-trigger";
        };
      };

      nixos =
        let
          timeout = 10;
          ts = builtins.toString;
        in
        {
          boot.kernelParams = [
            "efi_pstore.pstore_disable=0"
            "hardlockup_panic=1"
            "panic=${ts timeout}"
            "reboot=bios"
            "softlockup_panic=1"
          ];

          boot.kernelModules = [ "iTCO_wdt" ];

          systemd.settings.Manager = {
            KExecWatchdogSec = null;
            RebootWatchdogSec = "${ts (timeout * 2)}s";
            RuntimeWatchdogSec = "${ts timeout}s";
            WatchdogDevice = "/dev/watchdog";
          };

          boot.crashDump.enable = true;
        };
    };
  };
}
