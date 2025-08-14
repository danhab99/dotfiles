import ../module.nix {
  name = "ssh";

  options = { lib }: with lib; {
    enableFail2Ban = mkEnableOption {
      type = types.str;
    };
  };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [ openssh ];

    nixos = {
      services.openssh = {
        enable = true;
        allowSFTP = true;
        authorizedKeysInHomedir = true;
        settings.PasswordAuthentication = false;
        forwardX11 = true;
      };

      networking.firewall  = {
        allowedTCPPorts = [ 22 ];
        allowedUDPPorts = [ 22 ];
      };

      services.fail2ban = {
        enable = cfg.enableFail2Ban;

        maxretry = 2;
        bantime = "1000h";
      };
    };
  };
}
