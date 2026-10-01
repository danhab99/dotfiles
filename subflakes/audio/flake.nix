{
  description = "audio";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "audio";

    options =
      { lib }:
        with lib;
        {
          enableBluetooth = lib.mkEnableOption "enableBluetooth";
          # Preferred mic when no Bluetooth headset is connected.
          # WirePlumber node.name match (supports ~ glob).
          preferredSourceMatch = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "~alsa_input.usb-046d_C270.*";
            description = ''
              Raise this microphone above built-in / dock mics. Bluetooth
              headset input still wins when connected. When echo cancel is
              enabled, the cancelled virtual source ranks above this.
            '';
          };
          enableEchoCancel = mkEnableOption "PipeWire WebRTC acoustic echo cancellation";
          # Exact hardware mic node.name that AEC listens to (not a glob).
          echoCancelCaptureTarget = mkOption {
            type = types.nullOr types.str;
            default = null;
            example = "alsa_input.usb-046d_C270_HD_WEBCAM_B238AF60-02.mono-fallback";
            description = ''
              Hardware source the echo-cancel capture stream should use.
              Pin this so AEC does not try to listen to its own virtual source.
            '';
          };
          # enableJACK = lib.mkEnableOption "enableJACK";
        };

    output =
      { pkgs
      , cfg
      , lib
      , ...
      }:
      let
        # Priority ladder (higher wins):
        #   1. Bluetooth headset sink/source (when connected)
        #   2. Echo-cancelled virtual mic (when enableEchoCancel)
        #   3. preferredSourceMatch (e.g. raw C270)
        #   4. everything else demoted below that
        #
        # Sink priorities stay ≤1500 so sink monitors cannot beat real mics.
        # When AEC is on, raw preferred mic stays available for capture but
        # ranks below echo_cancel.source (2300) so apps pick the cancelled mic.
        preferredSourcePriority = if cfg.enableEchoCancel then 2100 else 2200;

        preferredSourceConfig = lib.optionalAttrs (cfg.preferredSourceMatch != null) {
          "52-preferred-source" = {
            "monitor.alsa.rules" = [
              {
                matches = [
                  { "node.name" = cfg.preferredSourceMatch; }
                ];
                actions = {
                  update-props = {
                    "priority.session" = preferredSourcePriority;
                    "priority.driver" = preferredSourcePriority;
                  };
                };
              }
              {
                matches = [
                  { "node.name" = "~alsa_input.pci-.*"; }
                ];
                actions = {
                  update-props = {
                    "priority.session" = 1500;
                    "priority.driver" = 1500;
                  };
                };
              }
              {
                matches = [
                  { "node.name" = "~alsa_input.usb-Lenovo_.*"; }
                ];
                actions = {
                  update-props = {
                    "priority.session" = 1800;
                    "priority.driver" = 1800;
                  };
                };
              }
            ];
          };
        };

        bluetoothPriorityConfig = lib.optionalAttrs cfg.enableBluetooth {
          "53-prefer-bluetooth" = {
            "monitor.bluez.rules" = [
              {
                matches = [
                  { "node.name" = "~bluez_output.*"; }
                ];
                actions = {
                  update-props = {
                    "priority.session" = 1400;
                    "priority.driver" = 1400;
                  };
                };
              }
              {
                matches = [
                  { "node.name" = "~bluez_input.*"; }
                ];
                actions = {
                  update-props = {
                    "priority.session" = 2500;
                    "priority.driver" = 2500;
                  };
                };
              }
            ];
          };
        };

        # monitor.mode: tap the default sink's monitor (no virtual sink to
        # force apps through). Apps should record from echo_cancel.source.
        echoCancelModule = lib.optionalAttrs cfg.enableEchoCancel {
          "60-echo-cancel" = {
            "context.modules" = [
              {
                name = "libpipewire-module-echo-cancel";
                args =
                  {
                    "library.name" = "aec/libspa-aec-webrtc";
                    "monitor.mode" = true;
                    "aec.args" = {
                      "webrtc.gain_control" = false;
                      "webrtc.high_pass_filter" = true;
                      "webrtc.noise_suppression" = true;
                    };
                    "capture.props" = {
                      "node.name" = "echo_cancel.capture";
                      "node.description" = "Echo Cancel Capture";
                      "node.passive" = true;
                      # Capture is a stream, not a selectable mic.
                      "media.class" = "Stream/Input/Audio";
                    } // lib.optionalAttrs (cfg.echoCancelCaptureTarget != null) {
                      "node.target" = cfg.echoCancelCaptureTarget;
                    };
                    "source.props" = {
                      "node.name" = "echo_cancel.source";
                      "node.description" = "Echo Cancelled Microphone";
                      # Above raw C270 (2200), below Bluetooth mic (2500).
                      "priority.session" = 2300;
                      "priority.driver" = 2300;
                    };
                  };
              }
            ];
          };
        };
      in
      {
        packages = with pkgs; [
          alsa-utils
          pamixer
          pavucontrol
          playerctl
          pulseaudioFull
        ];

        homeManager = lib.optionalAttrs cfg.enableEchoCancel {
          # Sticky WirePlumber defaults can keep the built-in mic selected even
          # when echo_cancel.source has higher priority. Re-assert after login.
          systemd.user.services.echo-cancel-default-source = {
            Unit = {
              Description = "Prefer PipeWire echo-cancelled microphone";
              After = [
                "pipewire.service"
                "pipewire-pulse.service"
                "wireplumber.service"
              ];
            };
            Service = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = pkgs.writeShellScript "echo-cancel-default-source" ''
                set -euo pipefail
                for _ in $(seq 1 40); do
                  if ${pkgs.pulseaudio}/bin/pactl list short sources 2>/dev/null \
                    | ${pkgs.gnugrep}/bin/grep -q $'^[^[:space:]]\+\techo_cancel\\.source\t'; then
                    ${pkgs.pulseaudio}/bin/pactl set-default-source echo_cancel.source
                    exit 0
                  fi
                  sleep 0.5
                done
                exit 0
              '';
            };
            Install.WantedBy = [ "default.target" ];
          };
        };

        nixos = {
          hardware.bluetooth.enable = cfg.enableBluetooth;
          services.blueman.enable = cfg.enableBluetooth;

          security.rtkit.enable = true;

          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;

            extraConfig.pipewire = echoCancelModule;

            wireplumber = {
              enable = true;
              # WirePlumber often picks output-only profiles on laptop HDA
              # codecs, which hides the internal microphone entirely.
              extraConfig = {
                "51-alsa-duplex-profile" = {
                  "monitor.alsa.rules" = [
                    {
                      matches = [
                        { "device.name" = "~alsa_card.pci-[0-9a-f_.]+$"; }
                      ];
                      actions = {
                        update-props = {
                          "device.profile" = "output:analog-stereo+input:analog-stereo";
                        };
                      };
                    }
                  ];
                };
              } // preferredSourceConfig // bluetoothPriorityConfig;
            };
          };
        };
      };
  };
}
