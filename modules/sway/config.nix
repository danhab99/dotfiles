{
  pkgs,
  cfg,
  lib,
}:
let
  mod = "Mod4";
  fontSize = cfg.fontSize;
in
{
  modifier = mod;

  fonts = {
    names = [ "monospace" ];
    size = fontSize;
  };

  floating = {
    modifier = "Mod4";
    criteria = [
      { title = "Android Emulator"; }
      { app_id = "xpad"; }
    ];
  };

  window = {
    titlebar = false;
    border = 0;

    commands = [
      {
        command = "resize set 600 500";
        criteria = {
          app_id = "popup";
        };
      }
      {
        command = "fullscreen enable";
        criteria = {
          app_id = "hl2_linux";
        };
      }
      {
        command = "border pixel 0";
        criteria = {
          app_id = ".*";
        };
      }
    ];
  };

  gaps = {
    inner = 20;
    outer = 12;
    smartBorders = "off";
  };

  colors = {
    focused = {
      border = "#2f343f";
      background = "#2f343f";
      text = "#f3f4f5";
      indicator = "#333333";
      childBorder = "#2f343f";
    };
    unfocused = {
      border = "#2f343f00";
      background = "#2f343f00";
      text = "#676E7D";
      indicator = "#333333";
      childBorder = "#2f343f00";
    };
    focusedInactive = {
      border = "#2f343f00";
      background = "#2f343f00";
      text = "#676E7D";
      indicator = "#333333";
      childBorder = "#2f343f00";
    };
    urgent = {
      border = "#E53935";
      background = "#E53935";
      text = "#f3f4f5";
      indicator = "#333333";
      childBorder = "#E53935";
    };
  };

  bars = [ ]; # Waybar will be used instead

  keybindings =
    let
      lockScreenExe = "exec ${pkgs.swaylock-effects}/bin/swaylock -f";
    in
    {
      "Pause" = lockScreenExe;
      "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
      "XF86AudioLowerVolume" = "exec amixer sset Master 5%-";
      "XF86AudioRaiseVolume" = "exec amixer sset Master 5%+";
      "XF86AudioMute" = "exec amixer sset Master toggle";
      "XF86AudioMicMute" = "exec amixer sset Capture toggle";
      "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
      "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";
      "${mod}+p" = "exec grim -g \"$(slurp)\" - | wl-copy";
      "${mod}+w" = "exec brave";
      "${mod}+e" = "exec nemo";
      "${mod}+plus" = "gaps inner all minus 2";
      "${mod}+minus" = "gaps inner all plus 2";
      "XF86AudioPlay" = "exec playerctl play-pause";
      "XF86AudioNext" = "exec playerctl next";
      "XF86AudioPrev" = "exec playerctl previous";
      "XF86AudioStop" = "exec playerctl stop";
      "${mod}+s" = ''exec sleep 0.1 && wtype "¯\_(ツ)_/¯"'';
      "${mod}+Mod1+h" = "exec ydotool mousemove -- -10 0";
      "${mod}+Mod1+l" = "exec ydotool mousemove -- 10 0";
      "${mod}+Mod1+k" = "exec ydotool mousemove -- 0 -10";
      "${mod}+Mod1+j" = "exec ydotool mousemove -- 0 10";
      "${mod}+Shift+Mod1+h" = "exec ydotool mousemove -- -100 0";
      "${mod}+Shift+Mod1+l" = "exec ydotool mousemove -- 100 0";
      "${mod}+Shift+Mod1+k" = "exec ydotool mousemove -- 0 -100";
      "${mod}+Shift+Mod1+j" = "exec ydotool mousemove -- 0 100";
      "${mod}+Mod1+c" = "exec ydotool click 0xC0";
      "XF86Display" = "exec wdisplays";
      "XF86Messenger" = "exec xpad -n";
      "${mod}+n" = "exec xpad -n";
      "${mod}+c" = "exec kcalc";
      "${mod}+Shift+Ctrl+l" = "exec sleep 0.5 && wtype https://www.linkedin.com/in/danhabot/";
      "${mod}+Ctrl+g" = "exec sleep 0.5 && wtype https://github.com/danhab99";
      "${mod}+Ctrl+e" = "exec sleep 0.5 && wtype dan.habot@gmail.com";
      "${mod}+Ctrl+a" = "exec playerctl previous";
      "${mod}+Ctrl+d" = "exec playerctl next";
      "${mod}+Ctrl+w" = "exec amixer sset Master 5%+";
      "${mod}+Ctrl+s" = "exec amixer sset Master 5%-";
      "${mod}+Return" = "exec alacritty";
      "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && alacritty";
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
      "${mod}+Shift+r" = "restart";
      "${mod}+Shift+e" =
        "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway?' -B 'Yes, exit sway' 'swaymsg exit'";
      "${mod}+r" = "mode resize";
      "${mod}+d" = "exec wofi --show drun";
      "${mod}+Tab" = "exec wofi --show window";
      "${mod}+shift+x" = lockScreenExe;
    };

  workspaceOutputAssign =
    let
      screens = cfg.screen;
      getScreenIndex = i: lib.mod i (builtins.length screens);
      getScreen = i: builtins.elemAt screens (getScreenIndex i);
    in
    builtins.genList (
      i:
      let
        idx = if i > 0 then i - 1 else 0;
      in
      {
        workspace = builtins.toString i;
        output = getScreen idx;
      }
    ) 10;

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
    {
      command = "ssh-add ~/.ssh/id_rsa";
      always = true;
    }
    {
      command = "swaybg -o '*' -i ~/.config/wallpaper.png -m fill";
      always = true;
    }
    {
      command = "$HOME/.local/bin/ev-cmd --device-path /dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd >> ~/.log/ev-cmd.log";
      always = true;
    }
    {
      command = "$HOME/Documents/rust/logitech-g600-rs/target/debug/logitech-g600-rs --device-path /dev/input/by-id/usb-Logitech_Gaming_Mouse_G600_FED1B7EDC0960017-if01-event-kbd --config-path $HOME/.config/g600/g600.toml >> ~/.log/g600.log";
      always = true;
    }
  ];

  focus = {
    wrapping = "force";
    followMouse = true;
  };

  assigns = {
    "2" = [
      { app_id = "steam"; }
    ];
  };

  output = cfg.outputs;
}
