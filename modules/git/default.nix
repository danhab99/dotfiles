import ../module.nix {
  name = "git";

  options = { lib }: with lib; {
    signingKey = mkOption {
      type = types.str;
      description = "GPG signing key";
    };
    email = mkOption {
      type = types.str;
      description = "Email";
    };
  };

  output = { pkgs, cfg, ... }: let
    gitDiffBlame = pkgs.stdenv.mkDerivation {
      pname = "git-diff-blame";
      version = "unstable";

      src = pkgs.fetchFromGitHub {
        owner = "dmnd";
        repo = "git-diff-blame";
        rev = "master";
        sha256 = "sha256-hmk7wNI+KifACS220yAiRRon1LhL3RS/HeI93kCkcig=";
      };

      # perl needs to be in the runtime closure
      buildInputs = [ pkgs.perl ];

      dontBuild = true;

      installPhase = ''
        mkdir -p $out/bin
        cp git-diff-blame $out/bin/git-diff-blame

        # fix shebang from /usr/bin/perl -> Nix perl
        substituteInPlace $out/bin/git-diff-blame \
          --replace '#!/usr/bin/perl' "#!${pkgs.perl}/bin/perl"

        chmod +x $out/bin/git-diff-blame
      '';
    };
  in {
    packages = with pkgs; [
      lazygit
      dvc
      gitDiffBlame
      # git-ignore
      git-extras
    ];

    homeManager = {
      programs.git = {
        enable = true;

        settings = {
          pull.rebase = true;
          init.defaultBranch = "main";
          color = {
            ui = "auto";
            diff = "auto";
          };

          alias = {
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
            "track" = ''
              "branch --set-upstream-to=origin/$(git symbolic-ref --short HEAD)"'';
            "fetch-all" = "fetch --update-head-ok origin '*:*'";
            "clone-for-worktrees" = ''"!sh $HOME/git-clone-bare-for-worktrees.sh"'';
            "cutdown" = "worktree remove --force";
            "plant" = "worktree add";
            "root" = "rev-parse --show-toplevel";
            "heal" = "!sh -c 'git restore --staged . && git checkout .'";
            "ignore" = "update-index --assume-unchanged";
            "unignore" = "update-index --no-assume-unchanged";
            "ignored" = ''!git ls-files -v | grep "^[[:lower:]]"'';
            "story" = "!sh -c 'ls $(git root) && git status && git diff --stat'";
            "remain" = "!sh -c 'git fetch origin main && git rebase origin/main'";
            "rebase-main" = "!git fetch origin main && git rebase origin/main";
          };
        };
        
        userEmail = cfg.email;
        userName = "Dan Habot";

        signing = {
          key = cfg.signingKey;
          signByDefault = true;
        };

        ignores = [
          ".vim"
          "tags"
          "notes/"
          "__debug_bin*"
          "makefile"
          "*out"
          ".env"
          "storybook-static/"
          "*.aidoc.md"
          "result/"
        ];

        lfs.enable = true;
      };

      programs.gh = {
        enable = true;
      };
    };
  };
}
