import ../module.nix {
  name = "fzf";
  output =
    { ... }:
    {
      nixos = { };

      homeManager = {
        programs.fzf = {
          enable = true;
          enableZshIntegration = true;
        };
      };
    };
}
