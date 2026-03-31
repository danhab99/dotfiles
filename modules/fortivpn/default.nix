import ../_module.nix
{
  name = "fortivpn";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      openfortivpn
    ];

    homeManager = { };

    nixos = { };
  };
}
