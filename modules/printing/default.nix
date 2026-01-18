import ../module.nix {
  name = "printing";

  output =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        # ...
      ];

      nixos.services.printing.enable = true;
    };
}
