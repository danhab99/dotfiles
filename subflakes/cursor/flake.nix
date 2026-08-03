{
  description = "cursor";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "cursor";

    options = { lib, ... }: with lib; { };

    output = { pkgs, lib, ... }:
      let
        # Electron safeStorage needs libsecret at runtime and an explicit
        # password-store backend, or MCP OAuth (Figma/Slack) fails with
        # "Encryption is not available".
        code-cursor-wrapped = pkgs.symlinkJoin {
          name = "code-cursor-wrapped";
          paths = [ pkgs.code-cursor ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/cursor \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.libsecret ]} \
              --add-flags "--password-store=basic"
          '';
        };
      in
      {
        packages = with pkgs; [
          cursor-cli
          code-cursor-wrapped
        ];

        homeManager = { };
        nixos = { };
      };
  };
}
