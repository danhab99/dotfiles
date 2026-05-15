{
  description = "Laptop NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    openclaw.url = "github:openclaw/nix-openclaw";
    nur.url = "github:nix-community/NUR";
    adirofi.url = "github:danhab99/rofi";
  } // (import ../_scanModules.nix).inputs;

  outputs = { self, nixpkgs, home-manager, nixos-hardware, openclaw, nur, adirofi, ... } @ inputs:

    let
      system = "x86_64-linux";

      hostConfig = {
        hostName = "laptop";
        inherit system;

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
            # screen = [ "eDP-1" ];
            screen = [ "DP-3-2" "DP-3-1" "DP-3-3-1" ];
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
          threedtools.enable = true;
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
          all-packages.enable = true;
          nixos-packages.enable = true;
        };

        i3Config = { mod }: {
          keybindings = {
            "Mod4+Shift+Return" = "exec urxvt -e ssh -S /tmp/ssh-master-desktop.sock desktop";
          };
        };
      };

      # Discover all available module subflakes
      scannedModules = import ../_scanModules.nix;
      modulesDir = ../subflakes/modules;
      moduleDirs = scannedModules.moduleDirs;

      # Extract enabled module names
      enabledModuleNames = builtins.filter (name:
        hostConfig.module.${name}.enable or false
      ) (builtins.attrNames hostConfig.module);

      # For each enabled module, import its flake and get its outputs
      loadModuleFlake = moduleName:
        let
          modulePath = modulesDir + "/${moduleName}";
          moduleFlakeFile = import "${modulePath}/flake.nix";
          moduleInputs = {
            self = { };
            nixpkgs = inputs.nixpkgs;
            home-manager = inputs.home-manager;
            flake-utils = inputs.nixpkgs;
          };
        in
        moduleFlakeFile.outputs moduleInputs;

      enabledModuleInputs = builtins.listToAttrs (
        builtins.map (moduleName: {
          inherit moduleName;
          value = loadModuleFlake moduleName;
        }) enabledModuleNames
      );

      mkMachineFlake = import ../_helpers.nix;
    in
    mkMachineFlake {
      name = "laptop";
      inherit system enabledModuleInputs hostConfig inputs;
      hardwareConfigPath = ./hardware-configuration.nix;
      outputFn = null;
    };
}
