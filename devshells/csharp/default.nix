{ pkgs, ... }: {
  name = "csharp";

  buildInputs = with pkgs; [
    csharp-ls
    python3
  ];

  shellHook = ''
  '';
}
