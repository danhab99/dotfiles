import ../module.nix {
  name = "ratbag";

  output = { pkgs, ... }: {
    packages = with pkgs;
      [
        libratbag
      ];

    nixos.services.ratbagd = { enable = true; };
  };
}
