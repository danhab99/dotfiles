import ../module.nix
{
  name = "metis";

  output = { pkgs, lib, ... }:
    let


      metis = pkgs.stdenv.mkDerivation rec {
        name = "metis-driver";
        src = builtins.fetchurl {
          url = "https://software.axelera.ai/artifactory/axelera-apt-source/metis-dkms/metis-dkms_0.07.16_all.deb";
          sha256 = "d39a80bdbb45d5b172110955d7ef5ee9600a33bc6756fa0f2db7431f20a9dcef";
        };

        buildInputs = with pkgs; [ dpkg ];

        unpackPhase = ''
          dpkg -x $src $TMPDIR/metis
        '';

        installPhase = ''
          targetDir="$out/lib/modules/$(uname -r)/updates/dkms"
          mkdir -p $targetDir

          # Copy necessary files
          cp -r $TMPDIR/metis/* $targetDir/

          # Ensure the dkms.conf file is in the correct location
          cp $TMPDIR/metis/usr/src/metis-0.07.16/dkms.conf $targetDir/

          # Set appropriate permissions for the copied files
          chmod -R u+rwX $targetDir
        '';
      };

    in
    {
      packages = with pkgs; [
        metis
      ];

      homeManager = { };

      nixos = {
        boot.kernelModules = [ "metis" ];

        # systemd.services.metis-driver = {
        #   description = "Axelera Metis Driver Service";
        #   wantedBy = [ "multi-user.target" ];
        #   serviceConfig.ExecStart = "${pkgs.docker}/bin/docker run --rm -v /dev:/dev metis-driver";
        # };
      };
    };
}
