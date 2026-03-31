import ../_template.nix {
  name = "worktrees";
  description = "worktrees";
  path = ./_files;
  welcomeText = ''
    To get started run `make init repo=[git repo url]`
  '';
}
