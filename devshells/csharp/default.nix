import ../devshell.nix {
  name = "csharp";

  versions =
    { pkgs, ... }:
    let
      shared = with pkgs; [
        csharp-ls
        python3
      ];
    in
    {
      "6" = {
        packages =
          (with pkgs; [
            dotnet-sdk_6
          ])
          ++ shared;
      };
      "8" = {
        packages =
          (with pkgs; [
            csharp-ls
            python3
            dotnetCorePackages.dotnet_8.sdk
            dotnetCorePackages.dotnet_8.aspnetcore
            dotnetPackages.Nuget
          ])
          ++ shared;
      };
    };
}
