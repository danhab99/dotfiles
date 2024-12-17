{ pkgs, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttle = 3 * 8.64e+7;
      max-cache-ttl = 3 * 8.64e+7;
    };
    pinentryPackage = pkgs.pinentry-curses;
  };
}
