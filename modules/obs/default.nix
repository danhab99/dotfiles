import ../module.nix
{
  name = "obs";

  output = { pkgs, ... }: {
    packages = with pkgs; [

    ];

    nixos = {
      boot.kernelModules = [ "v4l2loopback" ];
      boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          wlrobs
          obs-pipewire-audio-capture
        ];
        enableVirtualCamera = true;
      };
    };
  };
}

