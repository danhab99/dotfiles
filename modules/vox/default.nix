import ../module.nix
{
  name = "vox";

  output = { pkgs, ... }:
    let
      whisperModel =
        "${pkgs.whisper-cpp}/share/whisper/models/base.en.ggml.bin";

      voxToggle = pkgs.writeShellScriptBin "vox-toggle" ''
        set -euo pipefail

        LOGDIR="/home/dan/.log"
        LOGFILE="$LOGDIR/vox.log"
        PLAYER_STATE_FILE="/tmp/vox.player_state"

        mkdir -p "$LOGDIR"

        # Redirect ALL output (stdout + stderr) to the log
        exec >>"$LOGFILE" 2>&1

        log() {
          echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
        }

        log "=== vox-toggle invoked ==="

        PIDFILE="/tmp/arecord.pid"
        AUDIO="/tmp/record.wav"
        OUTTXT="/tmp/out.txt"

        beep() {
          freq="$1"
          # duration="$2"
          duration="0.15"
          log "beep freq=$freq duration=$duration"

          ${pkgs.sox}/bin/sox \
            -n -r 44100 -c 1 \
            /tmp/beep.wav \
            synth "$duration" sine "$freq" \
            vol 0.1

          ${pkgs.pulseaudio}/bin/paplay /tmp/beep.wav
          rm -f /tmp/beep.wav
        }

        get_player_state() {
          playerctl status 2>/dev/null || echo "NoPlayer"
        }

        pause_player_if_playing() {
          state="$(get_player_state)"
          log "player state before recording: $state"
          echo "$state" > "$PLAYER_STATE_FILE"

          if [ "$state" = "Playing" ]; then
            log "pausing player"
            playerctl pause || true
          fi
        }

        resume_player_if_needed() {
          if [ ! -f "$PLAYER_STATE_FILE" ]; then
            log "no saved player state"
            return
          fi

          prev_state="$(cat "$PLAYER_STATE_FILE")"
          log "restoring player state: $prev_state"

          if [ "$prev_state" = "Playing" ]; then
            log "resuming player"
            playerctl play || true
          fi

          rm -f "$PLAYER_STATE_FILE"
        }

        # ---------- STOP RECORDING ----------
        if [ -f "$PIDFILE" ]; then
          REC_PID="$(cat "$PIDFILE")"
          log "stop requested, pid=$REC_PID"

          if kill -0 "$REC_PID" 2>/dev/null; then
            log "sending SIGINT to ffmpeg to finalize WAV"
            kill -INT "$REC_PID"
            wait "$REC_PID" 2>/dev/null || true
          fi

          rm -f "$PIDFILE"

          # Low beep = stop
          beep 500 0.15

          # Wait a moment for file to be fully written
          sleep 0.2

          resume_player_if_needed

          if [ ! -f "$AUDIO" ] || [ ! -s "$AUDIO" ]; then
            log "ERROR: audio file missing or empty"
            beep 400 0.5
            exit 1
          fi

          MODEL="/home/dan/.local/share/whisper/ggml-base.en.bin"
          log "using model: $MODEL"

          if [ ! -f "$MODEL" ]; then
            log "ERROR: model not found"
            beep 400 0.5
            exit 1
          fi

          beep 520 0.15
          log "starting transcription"
          TRANSCRIPTION=$(${pkgs.whisper-cpp}/bin/whisper-cli \
            -m "$MODEL" \
            -f "$AUDIO" \
            -nt \
            2>&1 | grep -v "^whisper" | grep -v "^main:" | grep -v "^system_info:" | grep -v "^load_backend:" | grep -v "^\[" | grep -v "^$" | sed 's/\x1b\[[0-9;]*m//g')
          
          # Trim leading/trailing whitespace
          TRANSCRIPTION=$(echo "$TRANSCRIPTION" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

          log "transcription finished"
          log "transcription text: $TRANSCRIPTION"

          if [ -z "$TRANSCRIPTION" ]; then
            log "ERROR: transcription is empty"
            beep 400 0.5
            exit 1
          fi

          beep 540 0.15
          log "typing output"
          ${pkgs.xdotool}/bin/xdotool type "$TRANSCRIPTION"

          rm -f "$AUDIO"

          log "cleanup complete, exiting"
          exit 0
        fi

        # ---------- START RECORDING ----------
        log "start recording"

        pause_player_if_playing

        beep 440 0.08

        rm -f "$AUDIO"

        ${pkgs.ffmpeg}/bin/ffmpeg \
          -f pulse \
          -i alsa_input.usb-046d_0825_9476ED00-02.mono-fallback \
          -ar 16000 \
          -ac 1 \
          -fflags nobuffer \
          -flags low_delay \
          -probesize 32 \
          -y \
          "$AUDIO" >/dev/null 2>&1 &

        echo $! > "$PIDFILE"
        log "ffmpeg started, pid=$(cat "$PIDFILE")"
        
        # Small delay to ensure ffmpeg has started capturing
        sleep 0.1
        beep 460 0.08
      '';
    in
    {
      packages = with pkgs; [
        whisper-cpp
        xdotool
        pulseaudio
        sox
        ffmpeg
        voxToggle
      ];

      homeManager = {
        xsession.windowManager.i3.config = {
          keybindings = {
            "Mod4+Mod1+v" = "exec --no-startup-id vox-toggle";
          };
        };
      };

      nixos = {
        services.udev.extraRules = ''
          KERNEL=="uinput", GROUP="input", MODE="0620", OPTIONS+="static_node=uinput"
        '';
      };
    };
}
