import ../module.nix
{
  name = "n8n";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      nodejs_24
    ];

    homeManager = { };

    nixos = {
      services.n8n = {
        enable = true;

        environment = {
          "N8N_SECURE_COOKIE" = "false";
          "N8N_RUNNERS_ENABLED" = "true";
          "N8N_RUNNERS_MODE" = "internal";
        };

        customNodes =
          let
            mkNode = { version, owner, repo, hash, npmDepsHash }: pkgs.buildNpmPackage (finalAttrs: {
              inherit version npmDepsHash;
              pname = "n8n-${owner}-${repo}";

              src = pkgs.fetchFromGitHub {
                inherit repo owner hash;
                tag = "${finalAttrs.version}";
              };

              # eslint-plugin-n8n-nodes-base has a preinstall hook that enforces
              # pnpm via `only-allow`, which fails in the Nix offline sandbox.
              # npmFlags applies --ignore-scripts to the npm ci step; the build
              # phase still runs via explicit `npm run build` so tsc is unaffected.
              npmFlags = [ "--ignore-scripts" ];
            });

            # mkNode = { version, owner, repo, hash, npmDepsHash }: pkgs.fetchFromGitHub {
            #   pname = "N8NCustomNode-${owner}-${repo}";
            #   inherit repo owner hash;
            #   tag = "${version}";
            # };
          in
          [
            (mkNode {
              owner = "scraperapi";
              repo = "n8n-nodes-scraperapi-official";
              version = "1.1.0";
              hash = "sha256-wr9bJHodsxPeBtRZdZ34077lSdt4zQhobKbDfR2za/M=";
              npmDepsHash = "sha256-6yE8WU1ShZnI3tc+FIJ9MBa6R4mWXjGVyKNvYUTVBsw=";
            })
          ];
      };

      systemd.services.n8n.path = with pkgs; [ python3 nodejs_24 ];

      module.nginx.virtualHosts."n8n.localhost".port = 5678;

    };
  };
}
