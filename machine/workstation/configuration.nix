{ pkgs, ... }:

{
  imports = [ ../../parts/default.nix ];

  config.modules = {
    appimage.enable = true;
    docker.enable = true;
    font.enable = true;
    i18n.enable = true;
    nix.enable = true;
    packages.enable = true;
    pipewire.enable = true;
    ratbag.enable = true;
    sddm.enable = true;
    secrets.enable = true;
    ssh.enable = true;
    steam.enable = true;
    timezone.enable = true;
    xserver.enable = true;
  };

  config = {
    users.users.dan = {
      isNormalUser = true;
      description = "dan";
      extraGroups = [ "networkmanager" "wheel" "docker" "input" "dialout" ];
      shell = pkgs.zsh;
    };

    environment.localBinInPath = true;

    services.dbus.enable = true;
    services.xserver.config = ''
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
  };
}
