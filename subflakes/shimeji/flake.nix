{
  description = "shimeji";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    shimeji-rs.url = "github:danhab99/shimeji-rs";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "shimeji";

    options = { lib, ... }: with lib; {
      characters = mkOption {
        type = types.attrsOf types.path;
        default = { };
        description = ''
          Shimeji character packs available to install, each value a
          directory containing the character's PNG frames plus a conf/
          subdirectory with actions.xml and behaviors.xml. shimeji-rs (see
          [[project-i3-shimeji-investigation]]) has no character chooser
          yet — exactly one entry is used (the first found); the
          attribute name is unused beyond documentation.
        '';
      };
    };

    output = { lib, pkgs, shimeji-rs, cfg, ... }:
      let
        shimeji-package = shimeji-rs.packages.${pkgs.system}.default;

        # shimeji-rs wants <pack-dir>/conf/{actions,behaviors}.xml plus a
        # flat <pack-dir>/img/*.png. The character pack checked into
        # characters/ instead has the PNGs living next to conf/ (that's
        # ShimeLinux's own img/<CharacterName>/ chooser layout), so
        # re-lay it out at build time rather than reshuffling the
        # checked-in pack.
        characterDir = builtins.head (builtins.attrValues cfg.characters);
        packDir = pkgs.runCommand "shimeji-pack-dir" { } ''
          mkdir -p $out/img
          ln -s ${characterDir}/conf $out/conf
          for f in ${characterDir}/*.png; do
            ln -s "$f" "$out/img/$(basename "$f")"
          done
        '';
      in
      {
        homeManager = {
          # shimeji-rs creates its window with override_redirect set (see
          # shimeji-x11's render_argb.rs/render_shape.rs), the same trick
          # oneko has always used — it opts out of window-manager
          # participation entirely, so unlike ShimeLinux's Swing JWindow
          # (see [[project-i3-shimeji-investigation]]) it never needs the
          # old floating.criteria / "border none" i3 workarounds, and can't
          # trip i3-rounded's frame-handling code paths at all. No i3
          # config needed here any more.
          systemd.user.services.brushbuddy = {
            Unit = {
              Description = "shimeji-rs desktop mascot (brushbuddy)";
              After = [ "graphical-session-pre.target" ];
              PartOf = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${shimeji-package}/bin/shimeji --pack-dir ${packDir}";
              Restart = "on-failure";
              RestartSec = 2;
            };
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
          };
        };
      };
  };
}
