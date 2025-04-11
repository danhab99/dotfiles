import ../module.nix {
  name = "timezone";

  output = { ... }: {
    nixos.time.timeZone = "America/New_York";
    # nixos.time.timeZone = "Asia/Jerusalem";
  };
}
