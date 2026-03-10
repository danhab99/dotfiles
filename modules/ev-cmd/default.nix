import ../module.nix
{
  name = "ev-cmd";

  options = { lib }: with lib; {
    devicePath = mkOption { };
    deviceName = mkOption { };
  };

  output = { pkgs, ev-cmd, cfg, ... }:
    let
      ev-cmd-pkg = ev-cmd.packages.x86_64-linux.default;
    in
    {
      packages = with pkgs; [
        ev-cmd-pkg
      ];

      homeManager = {
        wayland.windowManager.sway.config.startup = [
          {
            command = "${ev-cmd-pkg}/bin/ev-cmd --device-path ${cfg.devicePath} --config-path ${./ev-cmd.toml} >> ~/.log/ev-cmd.log";
            always = true;
          }
        ];

      };

      nixos = { };
    };
}
