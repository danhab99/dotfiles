{
  description = "ssh";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "ssh";

    options =
      { lib }:
      with lib;
      {
        enableFail2Ban = mkEnableOption "fail2ban";
      };

    output =
      { pkgs, cfg, lib, ... }:
      {
        packages = with pkgs; [ openssh ];

        nixos = {
          services.openssh = {
            enable = true;
            allowSFTP = true;
            authorizedKeysInHomedir = true;
            settings.PasswordAuthentication = lib.mkForce false;
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
  };
}
