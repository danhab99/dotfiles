{ ... }:

{
  programs.git = {
    enable = true;

    extraConfig = {
      pull = {
        rebase = true;
      };
    };

    aliases = {
      "unstage" = "reset HEAD --";
      "nicelog" = "log --graph --oneline";
      "nl" = "log --graph --oneline";
      "last" = "show HEAD --show-signature --name-only";
      "delete" = "branch -D";
      "undo" = "reset HEAD~1 --mixed";
      "rank" = "shortlog -s -n --all";
      "push-this" = "push origin HEAD";
      "test-push" = "push --dry-run --all origin";
      "fixed" = ''commit . -m "fix"'';
      "wtf" = ''commit -m "$(curl -s whatthecommit.com/index.txt)"'';
      "unpushed" = ''
        "!sh -c 'git log --oneline remotes/origin/$( git rev-parse --abbrev-ref HEAD )~1..$( git rev-parse --abbrev-ref HEAD )' -"'';
      "pull-this" =
        ''"!sh -c 'git pull origin $(git rev-parse --abbrev-ref HEAD)'"'';
      "track" =
        ''"branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD)"'';
      "fetch-all" = "fetch --update-head-ok origin '*:*'";
      "clone-for-worktrees" = ''"!sh $HOME/git-clone-bare-for-worktrees.sh"'';
      "cutdown" = "worktree remove --force";
      "plant" = "worktree add";
      "root" = "rev-parse --show-toplevel";
      "heal" = "!sh -c 'git restore --staged . && git checkout .'";
      "ignore" = "update-index --assume-unchanged";
      "unignore" = "update-index --no-assume-unchanged";
      "ignored" = "!git ls-files -v | grep \"^[[:lower:]]\"";
      "story" = "!sh -c 'ls $(git root) && git status && git diff --stat'";
      "re-main" = "rebase main";
    };

    userEmail = "dan.habot@gmail.com";
    userName = "Dan Habot";

    signing = {
      key = "1DC36AE6EEEFDB55FE5D8874BAABD1E3FA0A9FB6";
      signByDefault = true;
    };

    ignores = [ ".vim" "tags" "notes/" "__debug_bin*" "makefile" "out" ".env" ];
  };
}
