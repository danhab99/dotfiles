import ../user.nix {
  name = "dan";

  extraGroups = [
    "networkmanager"
    "wheel"
    "docker"
    "input"
    "dialout"
    "tty"
    "video"
    "plugdev"
    "vboxusers"
  ];

  shell = pkgs: pkgs.zsh;

  sessionVariables = pkgs: with pkgs; {
    BROWSER = firefox + "/bin/firefox";
    GIT_PAGER = bat + "/bin/bat";
  };
}
