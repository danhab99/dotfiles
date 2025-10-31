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
          huh = "analyze.sh";
          n = "note.sh";
          note = "note.sh";
          notes = "note.sh";
          wtf = "rag.sh";
          s = "scratch.sh";
        };

        initContent = "PATH=$PATH:${cfg.source-path}";
      };
    };
  };
}

