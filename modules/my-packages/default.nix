import ../_module.nix
{
  name = "my-packages";
  requires = {
    duh.url = "github:danhab99/duh/main";
    # grit.url = "github:danhab99/grit/main";
  };

  output = { pkgs, duh, ... }: {
    packages = with pkgs; [
      duh.packages.x86_64-linux.duh
      # grit.packages.x86_64-linux.default
    ];

  };
}
