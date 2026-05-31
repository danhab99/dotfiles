{
  description = "worktrees";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "worktrees";

    template = ../../../modules/worktrees/_files;

    templateWelcome = ''
      To get started run `make init repo=[git repo url]`
    '';
  };
}
