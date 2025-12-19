inputs@{ pkgs, ... } : 
let
  node22 = import ../node22 inputs;
in {
  name = "node22prisma";

  buildInputs = with pkgs; [
    # ...
  ] ++ node22.buildInputs;

  PRISMA_QUERY_ENGINE_LIBRARY =
    "${pkgs.prisma-engines}/lib/libquery_engine.node";
  PRISMA_QUERY_ENGINE_BINARY =
    "${pkgs.prisma-engines}/bin/query-engine";
  PRISMA_SCHEMA_ENGINE_BINARY =
    "${pkgs.prisma-engines}/bin/schema-engine";

  shellHook = ''
  '';
}
