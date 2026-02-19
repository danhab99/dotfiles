import ../module.nix
{
  name = "my-packages";

  output = { pkgs, duh, grit, ... }: {
    packages = with pkgs; [
      duh.packages.x86_64-linux.duh
      grit.packages.x86_64-linux.default
    ];

  };
}
