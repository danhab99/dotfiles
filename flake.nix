{
  description = "Dotfiles root flake";

  inputs = {
    # === Modules flake (provides all shared inputs) ===

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    all-packages.url = "path:./subflakes/all-packages";
    appimage.url = "path:./subflakes/appimage";
    audio.url = "path:./subflakes/audio";
    bitwarden.url = "path:./subflakes/bitwarden";
    blank.url = "path:./subflakes/blank";
    changelog.url = "path:./subflakes/changelog";
    cli-notes.url = "path:./subflakes/cli-notes";
    csharp.url = "path:./subflakes/csharp";
    default.url = "path:./subflakes/default";
    docker.url = "path:./subflakes/docker";
    droid-packages.url = "path:./subflakes/droid-packages";
    duh.url = "path:./subflakes/duh";
    essential-packages.url = "path:./subflakes/essential-packages";
    ev-cmd.url = "path:./subflakes/ev-cmd";
    firefox.url = "path:./subflakes/firefox";
    fixit-loop.url = "path:./subflakes/fixit-loop";
    font.url = "path:./subflakes/font";
    fortivpn.url = "path:./subflakes/fortivpn";
    fzf.url = "path:./subflakes/fzf";
    g600.url = "path:./subflakes/g600";
    gestures.url = "path:./subflakes/gestures";
    git.url = "path:./subflakes/git";
    gnupg.url = "path:./subflakes/gnupg";
    go.url = "path:./subflakes/go";
    i18n.url = "path:./subflakes/i18n";
    i3.url = "path:./subflakes/i3";
    jenkins.url = "path:./subflakes/jenkins";
    kdeconnect.url = "path:./subflakes/kdeconnect";
    libreoffice.url = "path:./subflakes/libreoffice";
    meshtastic.url = "path:./subflakes/meshtastic";
    mk.url = "path:./subflakes/mk";
    my-packages.url = "path:./subflakes/my-packages";
    n8n.url = "path:./subflakes/n8n";
    neovim.url = "path:./subflakes/neovim";
    nextjs.url = "path:./subflakes/nextjs";
    nginx.url = "path:./subflakes/nginx";
    nix.url = "path:./subflakes/nix";
    nixos-packages.url = "path:./subflakes/nixos-packages";
    node.url = "path:./subflakes/node";
    nvidia.url = "path:./subflakes/nvidia";
    obs.url = "path:./subflakes/obs";
    ollama.url = "path:./subflakes/ollama";
    openclaw.url = "path:./subflakes/openclaw";
    opencode.url = "path:./subflakes/opencode";
    printing.url = "path:./subflakes/printing";
    python.url = "path:./subflakes/python";
    qmk.url = "path:./subflakes/qmk";
    react.url = "path:./subflakes/react";
    redshift.url = "path:./subflakes/redshift";
    rescue.url = "path:./subflakes/rescue";
    rofi.url = "path:./subflakes/rofi";
    rtlsdr.url = "path:./subflakes/rtlsdr";
    rust.url = "path:./subflakes/rust";
    sddm.url = "path:./subflakes/sddm";
    secrets.url = "path:./subflakes/secrets";
    slack.url = "path:./subflakes/slack";
    soulseek.url = "path:./subflakes/soulseek";
    ssh.url = "path:./subflakes/ssh";
    steam.url = "path:./subflakes/steam";
    thinkpad.url = "path:./subflakes/thinkpad";
    threedtools.url = "path:./subflakes/threedtools";
    timezone.url = "path:./subflakes/timezone";
    tmux.url = "path:./subflakes/tmux";
    tty.url = "path:./subflakes/tty";
    urxvt.url = "path:./subflakes/urxvt";
    vbox.url = "path:./subflakes/vbox";
    vim.url = "path:./subflakes/vim";
    virtualbox.url = "path:./subflakes/virtualbox";
    vox.url = "path:./subflakes/vox";
    vscode.url = "path:./subflakes/vscode";
    watchdog.url = "path:./subflakes/watchdog";
    wireguard.url = "path:./subflakes/wireguard";
    worktrees.url = "path:./subflakes/worktrees";
    xdg.url = "path:./subflakes/xdg";
    xorg.url = "path:./subflakes/xorg";
    zoxide.url = "path:./subflakes/zoxide";
    zsh.url = "path:./subflakes/zsh";
  };

  outputs = inputs:
    let
      lib = inputs.nixpkgs.lib;

      subflakeEntries = builtins.readDir ./subflakes;
      subflakeNames = builtins.filter (
        name:
        subflakeEntries.${name} == "directory"
        && builtins.pathExists (./subflakes + "/${name}/flake.nix")
        && builtins.hasAttr name inputs
      ) (builtins.attrNames subflakeEntries);

      hasPublishedOutput = name:
        let
          flakeFile = ./subflakes + "/${name}/flake.nix";
          flakeText = builtins.readFile flakeFile;
          publishesDevshells = lib.hasInfix "devshells" flakeText;
          publishesTemplate = lib.hasInfix "template" flakeText;
        in
        publishesDevshells || publishesTemplate;

      outputSubflakes = builtins.filter (
        name: hasPublishedOutput name
      ) subflakeNames;

      # Merge a single output attr (devShells/templates) from every subflake input.
      collectOutput = outputName:
        builtins.foldl' (
          acc: name:
          let
            input = inputs.${name};
          in
          lib.recursiveUpdate acc (
            if builtins.hasAttr outputName input then builtins.getAttr outputName input else { }
          )
        ) { } outputSubflakes;
    in
    {
      devShells = collectOutput "devShells";
      templates = collectOutput "templates";
    };
}
