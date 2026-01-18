import ../devshell.nix {
  name = "go";

  versions =
    { self, pkgs, ... }:
    {
      "" = {
        packages = with pkgs; [
          go
          gopls
        ];

        env = {
          GO_PATH = "${self.outPath}/.go";
        };
      };
    };
}
