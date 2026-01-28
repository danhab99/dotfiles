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

  shell = pkgs: "${pkgs.zsh}/bin/zsh";

  sessionVariables =
    pkgs: with pkgs; {
      BROWSER = brave + "/bin/brave";
      GIT_PAGER = bat + "/bin/bat";
    };
}
