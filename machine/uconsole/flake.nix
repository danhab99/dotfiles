{
  description = "Laptop NixOS configuration";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-uconsole = {
      url = "github:nixos-uconsole/nixos-uconsole/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    all-packages.url = "path:../../subflakes/all-packages";
    appimage.url = "path:../../subflakes/appimage";
    audio.url = "path:../../subflakes/audio";
    bitwarden.url = "path:../../subflakes/bitwarden";
    blank.url = "path:../../subflakes/blank";
    changelog.url = "path:../../subflakes/changelog";
    cli-notes.url = "path:../../subflakes/cli-notes";
    csharp.url = "path:../../subflakes/csharp";
    default.url = "path:../../subflakes/default";
    docker.url = "path:../../subflakes/docker";
    droid-packages.url = "path:../../subflakes/droid-packages";
    duh.url = "path:../../subflakes/duh";
    essential-packages.url = "path:../../subflakes/essential-packages";
    ev-cmd.url = "path:../../subflakes/ev-cmd";
    firefox.url = "path:../../subflakes/firefox";
    font.url = "path:../../subflakes/font";
    fortivpn.url = "path:../../subflakes/fortivpn";
    fzf.url = "path:../../subflakes/fzf";
    g600.url = "path:../../subflakes/g600";
    gestures.url = "path:../../subflakes/gestures";
    git.url = "path:../../subflakes/git";
    gnupg.url = "path:../../subflakes/gnupg";
    go.url = "path:../../subflakes/go";
    i18n.url = "path:../../subflakes/i18n";
    i3.url = "path:../../subflakes/i3";
    jenkins.url = "path:../../subflakes/jenkins";
    kdeconnect.url = "path:../../subflakes/kdeconnect";
    libreoffice.url = "path:../../subflakes/libreoffice";
    meshtastic.url = "path:../../subflakes/meshtastic";
    mk.url = "path:../../subflakes/mk";
    my-packages.url = "path:../../subflakes/my-packages";
    n8n.url = "path:../../subflakes/n8n";
    neovim.url = "path:../../subflakes/neovim";
    nextjs.url = "path:../../subflakes/nextjs";
    nginx.url = "path:../../subflakes/nginx";
    nix.url = "path:../../subflakes/nix";
    nixos-packages.url = "path:../../subflakes/nixos-packages";
    node.url = "path:../../subflakes/node";
    nvidia.url = "path:../../subflakes/nvidia";
    obs.url = "path:../../subflakes/obs";
    ollama.url = "path:../../subflakes/ollama";
    openclaw.url = "path:../../subflakes/openclaw";
    opencode.url = "path:../../subflakes/opencode";
    printing.url = "path:../../subflakes/printing";
    python.url = "path:../../subflakes/python";
    qmk.url = "path:../../subflakes/qmk";
    ranger.url = "path:../../subflakes/ranger";
    react.url = "path:../../subflakes/react";
    redshift.url = "path:../../subflakes/redshift";
    rescue.url = "path:../../subflakes/rescue";
    rofi.url = "path:../../subflakes/rofi";
    rtlsdr.url = "path:../../subflakes/rtlsdr";
    rust.url = "path:../../subflakes/rust";
    sddm.url = "path:../../subflakes/sddm";
    secrets.url = "path:../../subflakes/secrets";
    slack.url = "path:../../subflakes/slack";
    soulseek.url = "path:../../subflakes/soulseek";
    ssh.url = "path:../../subflakes/ssh";
    steam.url = "path:../../subflakes/steam";
    thinkpad.url = "path:../../subflakes/thinkpad";
    threedtools.url = "path:../../subflakes/threedtools";
    timezone.url = "path:../../subflakes/timezone";
    tmux.url = "path:../../subflakes/tmux";
    tty.url = "path:../../subflakes/tty";
    urxvt.url = "path:../../subflakes/urxvt";
    vbox.url = "path:../../subflakes/vbox";
    vim.url = "path:../../subflakes/vim";
    virtualbox.url = "path:../../subflakes/virtualbox";
    vox.url = "path:../../subflakes/vox";
    vscode.url = "path:../../subflakes/vscode";
    watchdog.url = "path:../../subflakes/watchdog";
    wireguard.url = "path:../../subflakes/wireguard";
    worktrees.url = "path:../../subflakes/worktrees";
    xdg.url = "path:../../subflakes/xdg";
    xorg.url = "path:../../subflakes/xorg";
    zoxide.url = "path:../../subflakes/zoxide";
    zsh.url = "path:../../subflakes/zsh";
  };

  outputs = inputs: {
    nixosConfigurations.subflake = import ../output.nix inputs {
      hardware-configuration = ./hardware-configuration.nix;

      hostCfg = {
        name = "uconsole";
        system = "aarch64-linux";

        users = {
          dan.enable = true;
        };

        module = {
          all-packages.enable = false;
          appimage.enable = true;
          audio.enable = false;
          docker.enable = false;
          droid-packages.enable = false;
          font.enable = true;
          fzf.enable = true;
          gestures.enable = false;
          git = {
            enable = true;
            email = "dan.habot@gmail.com";
            # signingKey = "ed25519/0x92ECE5191F6421F8";
            signingKey = "0x92ECE5191F6421F8";
          };
          gnupg.enable = true;
          i18n.enable = true;
          i3 = {
            enable = true;
            screen = [ "eDP-1" ];
            defaultLayoutScript = "normal.sh";
            fontSize = 12.0;
            i3blocksConfig = ../laptop/i3blocks.conf;
            modKey = "Mod1";
            altModKey = "Mod2";
          };
          libreoffice.enable = false;
          neovim.enable = true;
          nix = {
            enable = true;
            remoteBuild = true;
          };
          nixos-packages.enable = false;
          nvidia.enable = false;
          obs.enable = false;
          ollama.enable = false;
          printing.enable = false;
          qmk.enable = false;
          ranger.enable = true;
          redshift.enable = false;
          rtlsdr.enable = true;
          sddm.enable = true;
          secrets.enable = true;
          ssh.enable = true;
          steam.enable = false;
          thinkpad.enable = false;
          threedtools.enable = false;
          timezone.enable = true;
          tmux.enable = true;
          urxvt.enable = true;
          vbox.enable = false;
          vim.enable = false;
          vscode.enable = false;
          watchdog.enable = false;
          wireguard.enable = false;
          xdg.enable = true;
          xorg = {
            enable = true;
            videoDrivers = [ "modesetting" ];
            fontSize = 18;
          };
          zoxide.enable = true;
          zsh.enable = true;
          essential-packages.enable = true;
          tty.enable = true;
          meshtastic.enable = true;
          rofi.enable = true;
        };

        output = system: inputs@{ nixos-uconsole, ... }: modules: (nixos-uconsole.lib.mkUConsoleSystem {
          inherit modules;
          specialArgs = inputs;
        });
      };
    };
  };
}
