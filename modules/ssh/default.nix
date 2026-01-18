import ../module.nix {
  name = "ssh";

  options =
    { lib }:
    with lib;
    {
      enableFail2Ban = mkEnableOption {
        name = "enableFail2Ban";
      };
    };

  output =
    { pkgs, cfg, ... }:
    {
      packages = with pkgs; [ openssh ];

      nixos = {
        services.openssh = {
          enable = true;
          allowSFTP = true;
          authorizedKeysInHomedir = true;
          settings.PasswordAuthentication = false;
          settings = {
            X11Forwarding = true;
          };
        };

        networking.firewall = {
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ 22 ];
        };

        services.fail2ban = {
          enable = cfg.enableFail2Ban;

          maxretry = 10;
          bantime = "10h";
        };
      };
    };
}
