{ lib, config, ... }:

lib.mkModule {
  name = "zoxide";

  output = { ... }: {
    homeManager = {
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
