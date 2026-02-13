import ../devshell.nix {
  name = "csharp";

  versions =
    inputs@{ pkgs, dotnet_8_nixpkgs, ... }:
    let
      nixpkgs_for_dotnet_8 = import dotnet_8_nixpkgs { system = "x86_64-linux"; };

      mkNeovim = import ../mkNeovim.nix inputs;

      shared = with pkgs; [
        csharp-ls
        python3
        (mkNeovim {
          plugins = with pkgs.vimPlugins; [

          ];
          coc = {
            "csharp-ls" = {
              "command" = "csharp-ls";
              "filetypes" = [ "cs" ];
              "rootPatterns" = [ "*.csproj" ];
            };
          };
        })
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
          (with nixpkgs_for_dotnet_8; [
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
