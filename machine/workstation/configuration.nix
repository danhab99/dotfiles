{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ gnome-keyring libsecret seahorse libratbag ];

  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
      enable = true;
    };
  }; 

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      false; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall =
      false; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  security.pam.services = {
    login.enableGnomeKeyring = true; # Enable for TTY login
    sddm.enableGnomeKeyring = true;
  };

  services.dbus.enable = true;

  services.displayManager = {
    sddm.enable = true;
    # defaultSession = "none+i3";
  };

  services.gnome.gnome-keyring = { enable = true; };

  services.openssh = {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = true;
    settings.PasswordAuthentication = false;
  };

  services.passSecretService.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "99-disable-bell" = {
        "context.properties" = { "module.x11.bell" = false; };
      };
    };
  };

  services.printing.enable = true;

  services.ratbagd = { enable = true; };

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true; # Optional if using startx
    videoDrivers = [ "nvidia" ];

    xautolock.enable = false;
    desktopManager.xterm.enable = false;

    # X.org configuration
    config = ''
      Section "Device"
        Identifier "GPU0"
        Driver "nvidia"
        Option "AllowFlipping" "True"
        Option "TripleBuffer" "True"
        Option "ForceFullCompositionPipeline" "True"
      EndSection

      Section "Monitor"
          Identifier "HDMI-0"
          Option "PreferredMode" "1920x1080"
      EndSection

      Section "Monitor"
          Identifier "DP-5"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "HDMI-0"
      EndSection

      Section "Monitor"
          Identifier "DP-1"
          Option "PreferredMode" "1920x1080"
          Option "RightOf" "DP-5"
      EndSection

      Section "Screen"
          Identifier "Screen0"
          Device "GPU0"
          Option "metamodes" "HDMI-0: 1920x1080 +0+0, DP-5: 1920x1080 +1920+0, DP-1: 1920x1080 +3840+0"
          Option "AllowIndirectGLXProtocol" "True"
          Option "TripleBuffer" "True"
      EndSection
    '';

    # Keyboard settings
    xkb = {
      layout = "us";
      variant = "";
    };
  };
}
