{ pkgs, ... }:
let
  csharp = import ../csharp { inherit pkgs; };
in
{
  name = "csharp8";

  buildInputs = (with pkgs; [
    dotnet-sdk_6
  ]) ++ csharp.buildInputs;

  shellHook = ''
  '';
}
