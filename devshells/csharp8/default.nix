{ pkgs, ... }:
let
  csharp = import ../csharp { inherit pkgs; };
in
{
  name = "csharp8";

  buildInputs = (with pkgs; [
    dotnetCorePackages.dotnet_8.sdk
    dotnetCorePackages.dotnet_8.aspnetcore
    dotnetPackages.Nuget
  ]) ++ csharp.buildInputs;

  shellHook = ''
  '';
}
