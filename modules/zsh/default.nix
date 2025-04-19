import ../module.nix {
  name = "zsh";

  output = { pkgs, ... }: {
    packages = with pkgs; [ 
      zsh 
      oh-my-zsh 
      htop-vim
      iftop
      iotop
      jq
      ncdu
      neofetch
      ranger
      rclone
      retry
      ripgrep
      rsync
      screen
    ];

    homeManager = {
      home.sessionVariables = {
        VI_MODE_SET_CURSOR = "true";
        VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = "true";
      };

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

          git-fix =
            "git submodule sync --recursive; git submodule update --init --recursive";
          ga = "git add";
          gaa = "git add .";
          gai = "git add -ip";
          gpl = "git pull";
          gd = "git diff";
          gds = "git diff --staged";
          gc = "git commit --verbose";
          gcf = "git commit -m 'fix'";
          gca = "git commit --amend --verbose";
          gp = "git push --all";
          gs = "git status";
          gwt = "git worktree list";
          gpt = "git push origin $(git rev-parse --abbrev-ref HEAD)";
          gco = "git checkout --ignore-other-worktrees";
          gsc =
            "git submodule sync --recursive; git submodule update --init --recursive";
          gf = "git fetch-all";
          cg = "cd $(git root)";
          grc = "git rebase --continue";
          vg = "vim +':Git mergetool'";
          gus = "git restore --staged -- ";
          gnl = "git nicelog";
          gaagc = "git add . && git commit -a --verbose";
          gaagca = "git add . && git commit --amend -a --verbose";
          gpta = "${gaagca} && ${gpt}";

          dc = "docker-compose";

          clip = "xclip -selection c";
          cfzf = ''cd "$(dirname $(fzf))"'';
          tf = "terraform";
          rmr = "rm -r";
          tn = "textnote";
          edithosts = "sudo vim /etc/hosts";
          c = "cat";
          d = "docker";
          lg = "lazygit";
          tfa = "terraform apply";
          tfaa = "terraform apply --auto-approve";
          tfd = "terraform destroy";
          tfdd = "terraform destroy --auto-approve";
          tfp = "terraform plan";
          tfi = "terraform init";

          zadd = "zoxide add";
          r = "ranger-cd";
          npmi = "npm install";
          npmr = "npm run";
          vcon = "z /etc/nixos && vim configuration.nix";
          vhome = "z /etc/nixos && vim home.nix";
          znix = "z /etc/nixos";

          cai = "aichat -r %functions%";

        };

        initExtra = builtins.readFile ./extras.sh;
      };
    };

    nixos = {
      programs.zsh.enable = true;
    };
  };
}
