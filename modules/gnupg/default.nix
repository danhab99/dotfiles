import ../module.nix {
  name = "gnupg";

  # output.packages = with pkgs; [ pass ];

  output =
    { pkgs, ... }:
    {
      nixos = { };

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

          pinentry.package = pkgs.pinentry-curses;

          enableZshIntegration = true;
        };
      };
    };
}
