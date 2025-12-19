{ pkgs, ... } : {
  name = "node22";

  buildInputs = with pkgs; [
    gnumake
    nodejs_22
    yarn 
    prettierd
  ];

  shellHook = ''
  '';
}
