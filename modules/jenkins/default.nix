import ../_module.nix
{
  name = "jenkins";

  output = { pkgs, lib, ... }: {
    packages = with pkgs; [

    ];

    homeManager = { };

    nixos = {
      services.jenkins = {
        enable = true;
        port = 20050;
        user = "dan";
        group = "users";
        extraGroups = [
          "users"
          "wheel"
          "tty"
          "video"
          "dialout"
          "networkmanager"
          "vboxusers"
          "docker"
          "input"
          "plugdev"
        ];

        withCLI = true;
      };

      systemd.services.jenkins.serviceConfig = {
        # Allow Jenkins jobs to traverse and use /home/dan.
        ProtectHome = lib.mkForce false;
        PrivateUsers = lib.mkForce false;
        ReadWritePaths = lib.mkAfter [
          "/home/dan"
        ];
      };
    };
  };
}
