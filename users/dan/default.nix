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
    EDITOR = vim-full + "/bin/vim";
    BROWSER = firefox + "/bin/firefox";
    GIT_PAGER = bat + "/bin/bat";
  };
}
