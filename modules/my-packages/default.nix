import ../_module.nix
{
  name = "my-packages";
  requires = {
    # grit.url = "github:danhab99/grit/main";
  };

  output = { pkgs, ... }: {
    packages = with pkgs; [
      # grit.packages.x86_64-linux.default
    ];

  };
}
