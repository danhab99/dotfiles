import ../_module.nix
{
  name = "n8n";

  output = { pkgs, ... }: {
    packages = with pkgs; [
      nodejs_24
    ];

    homeManager = { };

    nixos = 
    let
      # Helper functions for building n8n community nodes
      n8nExtensions = {
        # Build n8n node from npm registry (simple approach without npm dependencies)
        fromNpmSimple = { pname, version, hash }:
          pkgs.stdenv.mkDerivation {
            inherit pname version;

            src = pkgs.fetchurl {
              url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
              inherit hash;
            };

            installPhase = ''
              # Extract package
              tar -xf $src
              cd package
              
              # Install to proper n8n location  
              mkdir -p $out/node_modules/${pname}
              cp -r . $out/node_modules/${pname}/
              
              # Ensure package.json exists at root for n8n to detect the node
              if [ -f package.json ]; then
                cp package.json $out/node_modules/${pname}/
              fi
            '';

            dontBuild = true;
            dontStrip = true;
          };

        # Build n8n node from npm registry (full approach with npm dependencies)
        fromNpm = { pname, version, hash, npmDepsHash ? null }:
          pkgs.buildNpmPackage {
            inherit pname version;
            npmDepsHash = if npmDepsHash != null then npmDepsHash else pkgs.lib.fakeHash;

            src = pkgs.fetchurl {
              url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
              inherit hash;
            };

            # Place files in node_modules structure for n8n
            installPhase = ''
              mkdir -p $out/node_modules/${pname}
              cp -r . $out/node_modules/${pname}
            '';

            dontBuild = true;
          };

        # Build n8n node from GitHub source
        fromGitHub = { owner, repo, version, hash, npmDepsHash ? null }:
          pkgs.buildNpmPackage {
            pname = "n8n-${owner}-${repo}";
            inherit version;
            npmDepsHash = if npmDepsHash != null then npmDepsHash else pkgs.lib.fakeHash;

            src = pkgs.fetchFromGitHub {
              inherit owner repo hash;
              tag = version;
            };

            # Handle pre-install scripts that may fail in sandbox
            npmFlags = [ "--ignore-scripts" ];

            # Standard npm build for TypeScript-based nodes
            buildPhase = ''
              runHook preBuild
              npm run build || true
              runHook postBuild
            '';

            # Install to node_modules structure
            installPhase = ''
              mkdir -p $out/node_modules/n8n-${owner}-${repo}
              cp -r . $out/node_modules/n8n-${owner}-${repo}
            '';
          };
      };

      # ScraperAPI node using simple approach
      scraperapi = n8nExtensions.fromNpmSimple {
        pname = "n8n-nodes-scraperapi-official";
        version = "1.2.0";
        hash = "sha256-TITp2QUsfV/WJl1EltOMLrCZmEUOtlR1xHTbqsHwoGA=";
      };
    in
    {
      services.n8n = {
        enable = true;

        environment = {
          # Enable community packages for runtime installation
          "N8N_COMMUNITY_PACKAGES_ENABLED" = "true";
          "N8N_SECURE_COOKIE" = "false";
          "N8N_RUNNERS_ENABLED" = "true";
          "N8N_RUNNERS_MODE" = "internal";
        };

        # Declaratively installed community nodes
        customNodes = [
          # Working scraperapi node installation
          (pkgs.stdenv.mkDerivation {
            pname = "n8n-nodes-scraperapi-official";
            version = "1.2.0";
            
            src = pkgs.fetchurl {
              url = "https://registry.npmjs.org/n8n-nodes-scraperapi-official/-/n8n-nodes-scraperapi-official-1.2.0.tgz";
              hash = "sha256-TITp2QUsfV/WJl1EltOMLrCZmEUOtlR1xHTbqsHwoGA=";
            };
            
            installPhase = ''
              # Create the node_modules structure that n8n expects
              mkdir -p $out/node_modules/n8n-nodes-scraperapi-official
              
              # Extract and copy all files
              tar -xf $src --strip-components=1 -C $out/node_modules/n8n-nodes-scraperapi-official
            '';
            
            dontBuild = true;
            dontStrip = true;
          })
        ];
      };

      # Ensure required runtime dependencies are available
      systemd.services.n8n.path = with pkgs; [ 
        python3 
        nodejs_24 
        # Add other tools that community nodes might need:
        # curl wget git
      ];

      # Expose n8n via nginx
      module.nginx.virtualHosts."n8n.localhost".port = 5678;
    };
  };
}
