import ../devshell.nix {
  name = "node";

  versions =
    inputs@{ pkgs, ... }:
    let

      mkNeovim = import ../mkNeovim.nix inputs;


      packages = with pkgs; [
        gnumake
        nodejs_22
        yarn
        prettierd
        (mkNeovim {
          neovimPlugins = with pkgs.vimPlugins; [
            coc-css
            coc-html
            coc-tsserver
            coc-tailwindcss
          ];
        })
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
