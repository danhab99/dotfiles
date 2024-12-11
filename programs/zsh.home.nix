{ ... }:

{
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

    shellAliases = {
      cdh = "cd ~";
      ci3 = "cd ~/.config/i3";
      cnix = "cd /etc/nixos";
      browse = "nautilus --browser . &";
      vi = "gvim -v";
      vim = "gvim -v";
      v = "gvim -v";
      vv = "gvim -v .";
      vi3 = "gvim -v ~/.config/i3/config";
      valias = "gvim -v ~/.bash_aliases";
      vssh = "gvim -v ~/.ssh/config";
      vfz = "gvim -v $(fzf)";

      # alias l="ls"
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

      dc = "docker-compose";
      # alias gvim -vrc="vim ~/.vimrc"

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

      cai = "aichat -m claude -r %functions%";
    };

    initExtra = builtins.readFile ../config/zsh/extras;
  };
}
