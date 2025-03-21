import ../module.nix {
  name =  "threedtools";

  output = { pkgs, ... }: {
    packages = with pkgs; [ 
      freecad
      blender
      bambu-studio
    ];

    nixos = { };

    homeManager = { };
  };
}
