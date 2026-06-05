{
  description = "Laptop NixOS configuration";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
    nixosConfigurations.subflake = import ../machine.nix inputs {
      hardware-configuration = ./hardware-configuration.nix;

      hostCfg = {
        name = "laptop";
        system = "x86_64-linux";

        users = {
          dan.enable = true;
        };

        module = {
          appimage.enable = true;
          docker.enable = true;
          font.enable = true;
          fzf.enable = true;
          git = {
            enable = true;
            signingKey = "0x9D575F7BFF5A6CB4";
            email = "dan.habot@gmail.com";
          };
          gnupg.enable = true;
          i18n.enable = true;
          i3 = {
            enable = true;
            i3blocksConfig = ./i3blocks.conf;
            screen = [ "eDP-1" ];
            fontSize = 12.0;
            defaultLayoutScript = "";
          };
          nix = {
            enable = true;
            remoteBuild = true;
          };
          ollama.enable = false;
          printing.enable = true;
          sddm.enable = true;
          secrets.enable = true;
          ssh.enable = true;
          steam.enable = false;
          threedtools.enable = false;
          timezone.enable = true;
          urxvt.enable = true;
          xorg = {
            enable = true;
            videoDrivers = [ "modesetting" ];
            fontSize = 16;
            extraConfig = ''
              urxvt*depth: 0
              urxvt*blurRadius: 0
              urxvt*transparent: true
              urxvt*tintColor: #555
            '';
          };
          zoxide.enable = true;
          zsh.enable = true;
          thinkpad.enable = true;
          neovim.enable = true;
          ranger.enable = true;
          obs.enable = true;
          audio = {
            enable = true;
            enableBluetooth = true;
          };
          watchdog.enable = true;
          gestures = {
            enable = true;
            devicePath = "/dev/input/by-path/platform-i8042-serio-1-event-mouse";
          };
          vscode.enable = true;
          tmux.enable = true;
          xdg.enable = true;
          redshift.enable = true;
          essential-packages.enable = true;
          nginx.enable = true;
          kdeconnect.enable = true;
          vox = {
            enable = true;
            inputMic = "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source";
          };
          soulseek.enable = true;
          rofi.enable = true;
          duh.enable = true;
          opencode.enable = true;

          all-packages.enable = true;
          nixos-packages.enable = true;
        };

        i3Config =
          { mod }:
          {
            keybindings = {
              "Mod4+Shift+Return" = "exec urxvt -e ssh -S /tmp/ssh-master-desktop.sock desktop";
            };
          };

        jobs =
          { pkgs }:
          [
            {
              name = "ssh-desktop-channel";
              schedule = "*-*-*";
              script = ''
                rm -f /tmp/ssh-master-desktop.sock
                ${pkgs.openssh}/bin/ssh -N -M -S "/tmp/ssh-master-desktop.sock" -L 20080:localhost:20080 desktop
              '';
              packages = [ pkgs.openssh ];
              user = "dan";
            }
          ];
      };
    };
  };
}
