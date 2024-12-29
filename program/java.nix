{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    java-language-server
    jdk21_headless
    jdk8_headless
    openjdk
  ];

  programs.java = {
    enable = false;
    # package = pkgs.oraclejre8;
  };
}
