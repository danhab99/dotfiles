import ../_module.nix
{
  name = "slack";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      slack-cli
      slack
      slack-term
    ];
  };
}

