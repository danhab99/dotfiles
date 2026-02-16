import ../module.nix
{
  name = "my-packages";

  output = { pkgs, duh, ... }: {
    packages = with pkgs; [
      duh.packages.x86_64-linux.default
    ];

  };
}
