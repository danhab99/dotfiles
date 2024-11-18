{ pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dan";
  home.homeDirectory = "/home/dan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    nerdfonts
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "Iosevka" ]; })
    powerline-fonts
    fira-code
    fontconfig
    ranger
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "fira-code" ];
      sansSerif = [ "fira-code" ];
      serif = [ "fira-code" ];
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/g600" = {
      source = ./g600;
      recursive = true;
    };

    ".config/i3" = {
      source = ./i3;
      recursive = true;
    };

    ".config/rofi" = {
      source = ./rofi;
      recursive = true;
    };

    ".vim/desert256.vim" = { source = ./vim/desert256.vim; };

    ".vimrc" = { source = ./vim/vimrc; };

    ".gitignore" = { source = ./git/gitignore; };

    ".gitconfig" = { source = ./git/gitconfig; };

    ".Xdefaults" = { source = ./X/Xdefaults; };

    ".Xresources" = { source = ./X/Xresources; };

    ".urxvt/ext" = {
      source = ./urxvt/ext;
      recursive = true;
    };

    ".config/ev-cmd.toml" = { source = ./ev-cmd/ev-cmd.toml; };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/dan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = pkgs.vim-full + "/bin/vim";
    BROWSER = pkgs.brave + "/bin/brave";
    VI_MODE_SET_CURSOR = "true";
    VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = "true";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
    };

    initExtra = builtins.readFile ./zsh/extras;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
