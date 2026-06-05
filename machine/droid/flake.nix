{
  description = "droid NixOS configuration";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    all-packages.url = path:../../subflakes/all-packages;
    appimage.url = path:../../subflakes/appimage;
    atop.url = path:../../subflakes/atop;
    audio.url = path:../../subflakes/audio;
    bitwarden.url = path:../../subflakes/bitwarden;
    blank.url = path:../../subflakes/blank;
    changelog.url = path:../../subflakes/changelog;
    cli-notes.url = path:../../subflakes/cli-notes;
    csharp.url = path:../../subflakes/csharp;
    cursor.url = path:../../subflakes/cursor;
    default.url = path:../../subflakes/default;
    docker.url = path:../../subflakes/docker;
    droid-packages.url = path:../../subflakes/droid-packages;
    duh.url = path:../../subflakes/duh;
    essential-packages.url = path:../../subflakes/essential-packages;
    ev-cmd.url = path:../../subflakes/ev-cmd;
    firefox.url = path:../../subflakes/firefox;
    fixit-loop.url = path:../../subflakes/fixit-loop;
    font.url = path:../../subflakes/font;
    fortivpn.url = path:../../subflakes/fortivpn;
    fzf.url = path:../../subflakes/fzf;
    g600.url = path:../../subflakes/g600;
    gestures.url = path:../../subflakes/gestures;
    git.url = path:../../subflakes/git;
    gnupg.url = path:../../subflakes/gnupg;
    go.url = path:../../subflakes/go;
    i18n.url = path:../../subflakes/i18n;
    i3.url = path:../../subflakes/i3;
    jenkins.url = path:../../subflakes/jenkins;
    kdeconnect.url = path:../../subflakes/kdeconnect;
    libreoffice.url = path:../../subflakes/libreoffice;
    meshtastic.url = path:../../subflakes/meshtastic;
    mk.url = path:../../subflakes/mk;
    my-nix-flake.url = path:../../subflakes/my-nix-flake;
    my-packages.url = path:../../subflakes/my-packages;
    n8n.url = path:../../subflakes/n8n;
    neovim.url = path:../../subflakes/neovim;
    nextjs.url = path:../../subflakes/nextjs;
    nginx.url = path:../../subflakes/nginx;
    nix.url = path:../../subflakes/nix;
    nixos-packages.url = path:../../subflakes/nixos-packages;
    node.url = path:../../subflakes/node;
    nvidia.url = path:../../subflakes/nvidia;
    obs.url = path:../../subflakes/obs;
    ollama.url = path:../../subflakes/ollama;
    openclaw.url = path:../../subflakes/openclaw;
    opencode.url = path:../../subflakes/opencode;
    printing.url = path:../../subflakes/printing;
    python.url = path:../../subflakes/python;
    qmk.url = path:../../subflakes/qmk;
    ranger.url = path:../../subflakes/ranger;
    react.url = path:../../subflakes/react;
    redshift.url = path:../../subflakes/redshift;
    rescue.url = path:../../subflakes/rescue;
    rofi.url = path:../../subflakes/rofi;
    rtlsdr.url = path:../../subflakes/rtlsdr;
    rust.url = path:../../subflakes/rust;
    sddm.url = path:../../subflakes/sddm;
    secrets.url = path:../../subflakes/secrets;
    slack.url = path:../../subflakes/slack;
    smartgit.url = path:../../subflakes/smartgit;
    soulseek.url = path:../../subflakes/soulseek;
    ssh.url = path:../../subflakes/ssh;
    steam.url = path:../../subflakes/steam;
    thinkpad.url = path:../../subflakes/thinkpad;
    threedtools.url = path:../../subflakes/threedtools;
    timezone.url = path:../../subflakes/timezone;
    tmux.url = path:../../subflakes/tmux;
    tty.url = path:../../subflakes/tty;
    urxvt.url = path:../../subflakes/urxvt;
    vbox.url = path:../../subflakes/vbox;
    vim.url = path:../../subflakes/vim;
    virtualbox.url = path:../../subflakes/virtualbox;
    vox.url = path:../../subflakes/vox;
    vscode.url = path:../../subflakes/vscode;
    watchdog.url = path:../../subflakes/watchdog;
    wireguard.url = path:../../subflakes/wireguard;
    worktrees.url = path:../../subflakes/worktrees;
    xdg.url = path:../../subflakes/xdg;
    xorg.url = path:../../subflakes/xorg;
    zoxide.url = path:../../subflakes/zoxide;
    zsh.url = path:../../subflakes/zsh;
  };

  outputs = inputs: {
    nixosConfigurations.subflake = import ../output.nix inputs {
      hardware-configuration = ./hardware-configuration.nix;

      hostCfg = {
        name = "droid";
        system = "x86_64-linux";

        users = {
          dan.enable = true;
        };

        module = {
          cli-notes.enable = true;
          csharp.enable = true;
          droid-packages.enable = true;
          duh.enable = true;
          essential-packages.enable = true;
          ev-cmd.enable = true;
          fixit-loop.enable = true;
          font.enable = true;
          fzf.enable = true;
          g600.enable = true;
          gestures.enable = true;
          git.enable = true;
          gnupg.enable = true;
          go.enable = true;
          i18n.enable = true;
          i3.enable = true;
          mk.enable = true;
          neovim.enable = true;
          nix.enable = true;
          python.enable = true;
          ranger.enable = true;
          secrets.enable = true;
          ssh.enable = true;
          tmux.enable = true;
          tty.enable = true;
          zoxide.enable = true;
          zsh.enable = true;
        };

        output = system: inputs@{ home-manager, nix-on-droid, nixpkgs, ... }: modules: (nix-on-droid.lib.nixOnDroidConfiguration {
          inherit modules;
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          specialArgs = inputs;
        });
      };
    };
  };
}
