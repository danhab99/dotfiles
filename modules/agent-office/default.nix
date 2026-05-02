import ../_module.nix
{
  name = "agent-office";

  output = { pkgs, ... }: {
    nixos = {
      services.agent-office = {
        enable = true;
        uiPort = 20090;
        port = 20091;
      };
    };
  };
}

