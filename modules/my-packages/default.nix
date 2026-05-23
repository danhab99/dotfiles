import ../_module.nix
{
  name = "my-packages";
  requires = {
    # grit.url = "github:danhab99/grit/main";
    duh.url = "github:danhab99/duh/main";
  };

  output = { pkgs, duh, ... }: {
    packages = with pkgs; [
      # grit.packages.x86_64-linux.default
      duh.packages.x86_64-linux.duh
    ];

  };
}
