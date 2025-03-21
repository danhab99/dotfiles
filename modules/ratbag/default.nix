import ../module.nix {
  name = "ratbag";

  output = { pkgs, ... }: {
    packages = with pkgs;
      [
        # ...
      ];

    nixos.services.ratbagd = { enable = true; };
  };
}
