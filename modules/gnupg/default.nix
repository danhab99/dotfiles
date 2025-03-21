{ pkgs, lib, config, ... }:

lib.mkModule {
  name = "gnupg";

  # output.packages = with pkgs; [ pass ];

  output = { ... }: {
    homeManager = {
      programs.gpg = {
        enable = true;
        mutableKeys = true;
      };

      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtl = 10000000;
        maxCacheTtl = 10000000;

        pinentryPackage = pkgs.pinentry-curses;
        enableZshIntegration = true;
      };
    };
  };
}
