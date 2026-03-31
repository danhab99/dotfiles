import ../_module.nix
{
  name = "ev-cmd";
  requires = {
    ev-cmd.url = "github:danhab99/ev-cmd/main";
  };

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
        xsession.windowManager.i3.config.startup = [
          {
            command = "xinput disable $$(xinput list --id-only '${cfg.deviceName}')";
            always = true;
          }
          {
            command = "${ev-cmd-pkg}/bin/ev-cmd --device-path ${cfg.devicePath} --config-path ${./ev-cmd.toml} >> ~/.log/ev-cmd.log";
            always = true;
          }
        ];

      };

      nixos = { };
    };
}
