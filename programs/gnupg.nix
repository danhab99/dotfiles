{ pkgs, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = "10000000";
      max-cache-ttl = "10000000";
    };
    pinentryPackage = pkgs.pinentry-curses;
  };
}
