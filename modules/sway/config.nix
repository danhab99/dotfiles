{ mod, fontSize, lockCmd, pkgs, cfg, lib, }: {
  modifier = mod;

  terminal = "foot";

  fonts = {
    names = [ "monospace" ];
    size = fontSize;
  };

  floating = {
    modifier = mod;
    criteria = [
      { app_id = "pavucontrol"; }
      { app_id = "wdisplays"; }
    ];
  };

  window = {
    titlebar = false;
    border = 0;
    commands = [
      {
        command = "border pixel 0";
        criteria = { app_id = ".*"; };
      }
      {
        command = "border pixel 0";
        criteria = { class = ".*"; };
      }
    ];
  };

  gaps = {
    inner = 20;
    outer = 12;
    smartBorders = "off";
  };

  # colors = {
  #   focused = {
  #     border = "#2f343f";
  #     background = "#2f343f";
  #     text = "#f3f4f5";
  #     indicator = "#333333";
  #     childBorder = "#2f343f";
  #   };
  #   unfocused = {
  #     border = "#2f343f00";
  #     background = "#2f343f00";
  #     text = "#676E7D";
  #     indicator = "#333333";
  #     childBorder = "#2f343f00";
  #   };
  #   focusedInactive = {
  #     border = "#2f343f00";
  #     background = "#2f343f00";
  #     text = "#676E7D";
  #     indicator = "#333333";
  #     childBorder = "#2f343f00";
  #   };
  #   urgent = {
  #     border = "#E53935";
  #     background = "#E53935";
  #     text = "#f3f4f5";
  #     indicator = "#333333";
  #     childBorder = "#E53935";
  #   };
  # };

  bars = [
    {
      command = "${pkgs.waybar}/bin/waybar";
    }
  ];

  keybindings = {
    "Pause" = "exec ${lockCmd}";
    "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
    "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
    "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
    "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
    "XF86AudioMicMute" = "exec ${pkgs.pamixer}/bin/pamixer --default-source -t";
    "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
    "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
    "${mod}+p" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
    "${mod}+w" = "exec brave";
    "${mod}+e" = "exec nemo";
    "${mod}+plus" = "gaps inner all minus 2";
    "${mod}+minus" = "gaps inner all plus 2";
    "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
    "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
    "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
    "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
    "${mod}+s" = "exec ${pkgs.wtype}/bin/wtype '¯\\_(ツ)_/¯'";
    "XF86Display" = "exec ${pkgs.wdisplays}/bin/wdisplays";
    "${mod}+c" = "exec ${pkgs.gnome-calculator}/bin/gnome-calculator";
    "${mod}+Shift+Ctrl+l" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'https://www.linkedin.com/in/danhabot/'";
    "${mod}+Ctrl+g" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'https://github.com/danhab99'";
    "${mod}+Ctrl+e" = "exec sleep 0.5 && ${pkgs.wtype}/bin/wtype 'dan.habot@gmail.com'";
    "${mod}+Ctrl+a" = "exec ${pkgs.playerctl}/bin/playerctl previous";
    "${mod}+Ctrl+d" = "exec ${pkgs.playerctl}/bin/playerctl next";
    "${mod}+Ctrl+w" = "exec ${pkgs.pamixer}/bin/pamixer -i 5";
    "${mod}+Ctrl+s" = "exec ${pkgs.pamixer}/bin/pamixer -d 5";
    "${mod}+Return" = "exec foot";
    "${mod}+Ctrl+Return" = "exec rm -f /tmp/workdir && foot";
    "${mod}+q" = "kill";
    "${mod}+h" = "focus left";
    "${mod}+j" = "focus down";
    "${mod}+k" = "focus up";
    "${mod}+l" = "focus right";
    "${mod}+Left" = "focus left";
    "${mod}+Down" = "focus down";
    "${mod}+Up" = "focus up";
    "${mod}+Right" = "focus right";
    "${mod}+Shift+h" = "move left";
    "${mod}+Shift+j" = "move down";
    "${mod}+Shift+k" = "move up";
    "${mod}+Shift+l" = "move right";
    "${mod}+Shift+Left" = "move left";
    "${mod}+Shift+Down" = "move down";
    "${mod}+Shift+Up" = "move up";
    "${mod}+Shift+Right" = "move right";
    "${mod}+v" = "split toggle";
    "${mod}+f" = "fullscreen toggle";
    "${mod}+Shift+space" = "floating toggle";
    "${mod}+space" = "focus mode_toggle";
    "${mod}+a" = "focus parent";
    "${mod}+1" = "workspace number 1";
    "${mod}+2" = "workspace number 2";
    "${mod}+3" = "workspace number 3";
    "${mod}+4" = "workspace number 4";
    "${mod}+5" = "workspace number 5";
    "${mod}+6" = "workspace number 6";
    "${mod}+7" = "workspace number 7";
    "${mod}+8" = "workspace number 8";
    "${mod}+9" = "workspace number 9";
    "${mod}+0" = "workspace number 10";
    "${mod}+Shift+1" = "move container to workspace number 1";
    "${mod}+Shift+2" = "move container to workspace number 2";
    "${mod}+Shift+3" = "move container to workspace number 3";
    "${mod}+Shift+4" = "move container to workspace number 4";
    "${mod}+Shift+5" = "move container to workspace number 5";
    "${mod}+Shift+6" = "move container to workspace number 6";
    "${mod}+Shift+7" = "move container to workspace number 7";
    "${mod}+Shift+8" = "move container to workspace number 8";
    "${mod}+Shift+9" = "move container to workspace number 9";
    "${mod}+Shift+0" = "move container to workspace number 10";
    "${mod}+Shift+c" = "reload";
    "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
    "${mod}+r" = "mode resize";
    "${mod}+d" = "exec app-launcher";
    "${mod}+Shift+w" = "exec waypaper";
    "${mod}+shift+x" = "exec ${lockCmd}";
  };

  modes = {
    resize = {
      "h" = "resize shrink width 5 px or 5 ppt";
      "j" = "resize grow height 5 px or 5 ppt";
      "k" = "resize shrink height 5 px or 5 ppt";
      "l" = "resize grow width 5 px or 5 ppt";
      "Left" = "resize shrink width 5 px or 5 ppt";
      "Down" = "resize grow height 5 px or 5 ppt";
      "Up" = "resize shrink height 5 px or 5 ppt";
      "Right" = "resize grow width 5 px or 5 ppt";
      "Return" = "mode default";
      "Escape" = "mode default";
      "${mod}+r" = "mode default";
    };
  };

  startup = [
    { command = "ssh-add ~/.ssh/id_rsa"; }
    { command = "${pkgs.mako}/bin/mako"; }
    { command = "${pkgs.swww}/bin/swww-daemon"; }
  ] ++ (lib.optional (cfg.wallpaper != null) {
    command = "${pkgs.swww}/bin/swww img ${cfg.wallpaper}";
    always = true;
  });

  focus = {
    wrapping = "force";
    followMouse = true;
    mouseWarping = true;
  };

  input = {
    "type:keyboard" = {
      xkb_layout = "us";
      xkb_options = "caps:none";
    };
    "type:touchpad" = {
      tap = "enabled";
      natural_scroll = "enabled";
      dwt = "enabled";
    };
  };

  assigns = {
    "2" = [
      { class = "steam"; }
      { class = "steam_app_2073850"; }
      { class = "steam_app_275850"; }
      { class = "steam_app_276703"; }
      { class = "tf_linux64"; }
    ];
  };
}
