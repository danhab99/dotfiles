{
  description = "node";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "node";

    devshells =
      { pkgs, ... }:
      let
        packages = with pkgs; [
          just
          nodejs_22
          yarn
          prettierd
        ];
      in
      {
        "22" = {
          inherit packages;
        };

        "22-prisma" = {
          inherit packages;
          env = {
            PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
            PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
            PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
          };
        };
      };
  };
}
