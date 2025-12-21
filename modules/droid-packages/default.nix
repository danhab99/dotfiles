import ../module.nix
{
  name = "droid-packages";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      openssh
      gnugrep
    ];
  };
}

