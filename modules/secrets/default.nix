import ../module.nix {
  name = "secrets";

  output = { pkgs, ... }: {
    packages = with pkgs;
      [
        # ...
      ];

    nixos = {
      security.rtkit.enable = true;

      security.pam.services = {
        login.enableGnomeKeyring = true; # Enable for TTY login
        sddm.enableGnomeKeyring = true;
      };

      services.gnome.gnome-keyring.enable = true;
      programs.seahorse.enable = true;

      services.passSecretService.enable = true;
    };
  };
}
