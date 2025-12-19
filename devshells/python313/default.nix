{ pkgs, ... } : {
  name = "python313";

  buildInputs = with pkgs; [
    gnumake
    python313
    python313Packages.requests
    python313Packages.pypandoc
    python313Packages.toml
  ];

  shellHook = ''
  '';
}
