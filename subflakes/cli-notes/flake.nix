{
  description = "cli-notes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "cli-notes";

    options =
      { lib }:
        with lib;
        {
          source-path = mkOption { };
        };

    output =
      { pkgs, cfg, ... }:
      let

        getLogFile = ''
          LOG_FILE="/home/$USER/Documents/activity-log/$(date +%Y-%m-%d).log"
          mkdir -p $(dirname $LOG_FILE)
        '';

        analyzesh = pkgs.writeShellScriptBin "analyze.sh" ''
          ${getLogFile}

          cat $LOG_FILE | tail -n 30 | bat

          aichat -m openai:gpt-4-turbo --rag activity-log --prompt "You are a helpful secretary who is really good at remembering what I have done. I will send you my activity log for you to summarize, focus on what I need to do and what is already done. Write lists, list everything that is done, and list everything that still needs to be doing, and list everything that I'm waiting for. The time is $(date +%T)." $(cat $LOG_FILE)
        '';

        notesh = pkgs.writeShellScriptBin "notes.sh" ''
          ${getLogFile}

          MESSAGE=$*

          w() {
              echo $* >> $LOG_FILE
          }

          w "========== $(date +%T-%N) =========="
          w From $(pwd)
          w ""
          w $MESSAGE
          w ""

          echo Logged...

          # aichat -m openai:gpt-4-turbo --prompt "You are a helpful secratary who makes reminders. I will show you a note that I want to add to my activity log, your job is to analyze that message and identify if you need to create a reminder
        '';

        ragsh = pkgs.writeShellScriptBin "rag.sh" ''
          ${getLogFile}

          aichat --rebuild-rag --rag activity-log
          aichat -m openai:gpt-4-turbo --session --rag activity-log --prompt "You are a helpful secratary. I have forgotten something and I need you to do your best to help me remember. You have access to my activity log in this context, limit yourself to strictly using this information and do not make anything up"
        '';

        todaysh = pkgs.writeShellScriptBin "today.sh" ''
          ${getLogFile}
          bat $LOG_FILE
        '';
      in
      {
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
          };
        };
      };
  };
}
