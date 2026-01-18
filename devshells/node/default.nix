import ../devshell.nix {
  name = "node";

  versions =
    { pkgs, ... }:
    let
      packages = with pkgs; [
        gnumake
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

}
