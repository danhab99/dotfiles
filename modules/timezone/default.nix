import ../module.nix {
  name = "timezone";

  output = { pkgs, ... }: {
    environment.systemPackages = with pkgs;
      [
        # ...
      ];

    # nixos.time.timeZone = "America/New_York";
    nixos.time.timeZone = "Asia/Jerusalem";

    homeManager = { };
  };
}
