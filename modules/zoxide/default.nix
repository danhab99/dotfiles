import ../module.nix {
  name = "zoxide";

  output =
    { ... }:
    {
      homeManager = {
        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };
      };

      nixos = { };

      homeManager = { };
    };
}
