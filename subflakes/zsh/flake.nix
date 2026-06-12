{
  description = "zsh";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "zsh";

    options =
      { lib }:
      with lib;
      {
        extras = mkOption {
          type = types.str;
          default = "";
        };
      };

    output =
      { pkgs, cfg, ... }:
      {
        packages = with pkgs; [
          bat
          zsh
          oh-my-zsh
          htop-vim
          iftop
          iotop
          jq
          ncdu
          fastfetch
          rclone
          retry
          ripgrep
          rsync
          screen
          xclip
        ];

        nixos = {
          programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
            loadInNixShell = false;
            silent = false;

            settings = {
              global = {
                warn_timeout = 0;
                hide_env_diff = true;
              };
            };
          };

          programs.zsh.enable = true;

          environment.sessionVariables = {
            VI_MODE_SET_CURSOR = "true";
            VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = "true";
            GOPATH = "/home/dan/Documents/go";
            BROWSER = "firefox";
          };
        };

        homeManager = {
          home.sessionVariables = {
            VI_MODE_SET_CURSOR = "true";
            VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = "true";
            GOPATH = "/home/dan/Documents/go";
            BROWSER = "firefox";
          };

          home.shell.enableZshIntegration = true;

          programs.zsh = {
            enable = true;
            enableCompletion = true;

            oh-my-zsh = {
              enable = true;

              plugins = [
                "git"
                "docker"
                "github"
                "lol"
                "node"
                "pip"
                "python"
                "screen"
                "sudo"
                "vscode"
                "brew"
                "colorize"
                "docker-compose"
                "fzf"
                "qrcode"
                "vi-mode"
              ];
              theme = "dstufft";
            };

            shellAliases = rec {
              cdh = "cd ~";
              ci3 = "cd ~/.config/i3";
              cnix = "cd /etc/nixos";
              browse = "nautilus --browser . &";
              vi = "vim";
              vim = "vim";
              v = "vim";
              vv = "vim .";
              vi3 = "vim ~/.config/i3/config";
              valias = "vim ~/.bash_aliases";
              vssh = "vim ~/.ssh/config";
              vfz = "vim $(fzf)";

              cg = "cd $(git root)";
              ga = "git add";
              gaa = "git add .";
              gaagc = "git add . && git commit -a --verbose";
              gaagca = "git add . && git commit --amend -a --verbose";
              gai = "git add -ip";
              gc = "git commit --verbose";
              gca = "git commit --amend --verbose";
              gcf = "git commit -m 'fix'";
              gco = "git checkout --ignore-other-worktrees";
              gd = "git diff";
              gds = "git diff --staged";
              gf = "git fetch-all";
              git-fix = "git submodule sync --recursive; git submodule update --init --recursive";
              gnl = "git nicelog";
              gp = "git push --all";
              gpl = "git pull";
              gpt = "git push origin $(git rev-parse --abbrev-ref HEAD)";
              gpta = "${gaagca} && ${gpt}";
              grc = "git rebase --continue";
              gs = "git status";
              gsc = "git submodule sync --recursive; git submodule update --init --recursive";
              gus = "git restore --staged -- ";
              gwt = "git worktree list";
              vg = "vim +':Git mergetool'";

              dc = "docker-compose";

              clip = "xclip -selection c";
              cfzf = ''cd "$(dirname $(fzf))"'';
              rmr = "rm -r";
              edithosts = "sudo vim /etc/hosts";

              lg = "lazygit";
              ld = "lazydocker";

              tf = "terraform";
              tfa = "terraform apply";
              tfaa = "terraform apply --auto-approve";
              tfd = "terraform destroy";
              tfdd = "terraform destroy --auto-approve";
              tfi = "terraform init";
              tfp = "terraform plan";

              zadd = "zoxide add";
              za = "zoxide add .";
              r = "ranger-cd";
              npmi = "npm install";
              npmr = "npm run";
              znix = "z /etc/nixos";

              cdtemp = "cd $(mktemp -d)";

              fix-redshift = "systemctl --user restart redshift";
              j = "just --choose";
              jj = "just default";

              oc = "opencode";
              c = "clear";
            };

            initContent = builtins.readFile ./extras.sh + cfg.extras;
          };
        };
      };
  };
}
