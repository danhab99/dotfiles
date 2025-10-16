import ../module.nix
{
  name = "cli-notes";

  options = { lib }: with lib; {
    source-path = mkOption {};
  };

  output = { pkgs, cfg, ... }: {
    packages = with pkgs; [

    ];

    homeManager = {
      programs.zsh = {
        shellAliases = {
          note = "note.sh";
          notes = "note.sh";
          n = "note.sh";
          wtf = "analyze.sh";
        };

        initContent = "PATH=$PATH:${cfg.source-path}";
      };
    };
  };
}

