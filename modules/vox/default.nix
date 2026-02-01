import ../module.nix
{
  name = "vox";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      voxinput
    ];

    homeManager = {
      xsession.windowManager.i3.config = {
        startup = [
          {
            command = "exec OPENAI_BASE_URL=\"http://localhost:11434/v1\" VOXINPUT_BASE_URL=\"http://localhost:11434/v1\" VOXINPUT_REALTIME=false voxinput listen";
          }
        ];

        keybindings = {
          "Mod4+Mod1+v" = "voxinput record";
          "Mod4+Shift+Mod1+v" = "voxinput write";
        };
      };
    };

    nixos = {
      services.udev.extraRules = ''
        KERNEL=="uinput", GROUP="input", MODE="0620", OPTIONS+="static_node=uinput"
      '';
    };
  };
}
