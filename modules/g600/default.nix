import ../module.nix
{
  name = "g600";

  options = { lib }: with lib; {
    devicePath = mkOption { };
    deviceName = mkOption { };
  };

  output = { pkgs, logitech-g600-rs, cfg, ... }:
    let
      logitech-g600-rs-pkg = logitech-g600-rs.packages.x86_64-linux.default;
    in
    {
      packages = with pkgs; [
        logitech-g600-rs-pkg
      ];

      homeManager = {
        xsession.windowManager.i3.config.startup = [
          {
            command = "xinput disable $$(xinput list --id-only '${cfg.deviceName}')";
            always = true;
          }
          {
            command = "${logitech-g600-rs-pkg}/bin/logitech-g600-rs --device-path ${cfg.devicePath} --config-path ${./g600.toml} >> ~/.log/g600.log";
            always = true;
          }
        ];

        home.file.".config/g600" = {
          recursive = true;
          source = ./assets;
        };

      };

      nixos = { };
    };
}
