import ../module.nix {
  name = "ssh";

  output = { pkgs, ... }: {
    packages = with pkgs; [ openssh ];

    nixos = {
      services.openssh = {
        enable = true;
        allowSFTP = true;
        authorizedKeysInHomedir = true;
        settings.PasswordAuthentication = false;
      };

      networking = {
        firewall = {
          allowedTCPPorts = [ 22 ];
          allowedUDPPorts = [ 22 ];
        };
      };
    };
  };
}
