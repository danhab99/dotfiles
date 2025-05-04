{ pkgs, cfg, lib }:
let
  mod = "Mod4";
in
{
  modifier = mod;

  fonts = {
    names = [ "monospace" ];
    size = 12.0;
  };

  floating = {
    modifier = "Mod4";
    criteria = [
      { title = "Android Emulator"; }
      { window_role = "pop-up"; }
      {
        class = "xpad";
        instance = "xpad";
      }
    ];
  };

  window = {
    titlebar = false;
    border = 0;

    commands = [
      {
        command = "resize set 600 500";
        criteria = { window_role = "pop-up"; };
      }
      {
        command = "fullscreen enable";
        criteria = { class = "hl2_linux"; };
      }
      {
        command = "border pixel 0";
        criteria = { class = "^.*"; };
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
      childBorder = "";
    };
    unfocused = {
      border = "#2f343f00";
      background = "#2f343f00";
      text = "#676E7D";
      indicator = "#333333";
      childBorder = "";
    };
    focusedInactive = {
      border = "#2f343f00";
      background = "#2f343f00";
      text = "#676E7D";
      indicator = "#333333";
      childBorder = "";
    };
    urgent = {
      border = "#E53935";
      background = "#E53935";
      text = "#f3f4f5";
      indicator = "#333333";
      childBorder = "";
    };
  };

  bars = [{
    position = "bottom";
    statusCommand = "${pkgs.i3blocks}/bin/i3blocks -c ${cfg.i3blocksConfig}";
    command = "i3bar -t";

    fonts = {
      names = [ "monospace" ];
      size = 12.0;
    };

    colors = {
      background = "#2f343f00";
      statusline = "#f3f4f5";
      separator = "#f3f4f5";
      focusedWorkspace = {
        border = "#2f343f";
        background = "#2f343f";
        text = "#f3f4f5";
      };
      inactiveWorkspace = {
        border = "#2f343f00";
        background = "#2f343f00";
        text = "#676E7D";
      };
      urgentWorkspace = {
        border = "#E53935";
        background = "#E53935";
        text = "#f3f4f5";
      };
    };
  }];

  keybindings = {
    "Pause" = "exec /home/dan/.config/i3/lock.sh";
    "XF86AudioLowerVolume" = "exec amixer sset Master 5%-";
    "XF86AudioRaiseVolume" = "exec amixer sset Master 5%+";
    "XF86AudioMute" = "exec amixer sset Master toggle";
    "XF86AudioMicMute" = "exec amixer sset Capture toggle";
    "XF86MonBrightnessUp" = "exec xbacklight -inc 10";
    "XF86MonBrightnessDown" = "exec xbacklight -dec 10";
    "${mod}+p" = "exec flameshot gui";
    "${mod}+w" = "exec brave";
    "${mod}+e" = "exec nemo";
    "${mod}+plus" = "gaps inner all minus 2";
    "${mod}+minus" = "gaps inner all plus 2";
    "${mod}+period" =
      "exec pacmd set-default-sink alsa_output.usb-SAVITECH_Bravo-X_USB_Audio-01.analog-stereo";
    "${mod}+comma" =
      "exec pacmd set-default-sink alsa_output.pci-0000_00_14.2.analog-stereo";
    "XF86AudioPlay" = "exec playerctl play-pause";
    "XF86AudioNext" = "exec playerctl next";
    "XF86AudioPrev" = "exec playerctl previous";
    "XF86AudioStop" = "exec playerctl stop";
    "${mod}+question" = "exec i3help";
    "${mod}+ctrl+V" = "exec ~/Documents/dotfiles/vgrep.x11.sh";
    "${mod}+s" = ''exec sleep 0.1 && xdotool type "¯\_(ツ)_/¯"'';
    "${mod}+Mod1+h" = "exec xdotool mousemove_relative -p 270 10";
    "${mod}+Mod1+l" = "exec xdotool mousemove_relative -p 90 10";
    "${mod}+Mod1+k" = "exec xdotool mousemove_relative -p 0 10";
    "${mod}+Mod1+j" = "exec xdotool mousemove_relative -p 180 10";
    "${mod}+Shift+Mod1+h" = "exec xdotool mousemove_relative -p 270 100";
    "${mod}+Shift+Mod1+l" = "exec xdotool mousemove_relative -p 90 100";
    "${mod}+Shift+Mod1+k" = "exec xdotool mousemove_relative -p 0 100";
    "${mod}+Shift+Mod1+j" = "exec xdotool mousemove_relative -p 180 100";
    "${mod}+Mod1+c" = "exec xdotool mousedown 1 && xdotool mouseup 1";
    "XF86Display" = "exec arandr";
    "XF86Messenger" = "exec xpad -n";
    "${mod}+n" = "exec xpad -n";
    "${mod}+c" = "exec kcalc";
    "${mod}+Shift+Ctrl+l" =
      "exec sleep 0.5 && xdotool type https://www.linkedin.com/in/danhabot/";
    "${mod}+Ctrl+g" =
      "exec sleep 0.5 && xdotool type https://github.com/danhab99";
    "${mod}+Ctrl+e" =
      "exec sleep 0.5 && xdotool type dan.habot@gmail.com";
    "${mod}+Ctrl+a" = "exec playerctl previous";
    "${mod}+Ctrl+d" = "exec playerctl next";
    "${mod}+Ctrl+w" = "exec amixer sset Master 5%+";
    "${mod}+Ctrl+s" = "exec amixer sset Master 5%-";
    "${mod}+Return" = "exec urxvt";
    "${mod}+Ctrl+Return" = "exec rm /tmp/workdir && urxvt";
    # "${mod}+Shift+Return" = "exec urxvt -e ssh -XY remotestation";
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
      "exec i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'";
    "${mod}+r" = "mode resize";
    "${mod}+d" = "exec $HOME/.config/rofi/scripts/launcher_t1";
    "${mod}+Tab" =
      "exec $HOME/.config/rofi/launchers/misc/launch_windows.sh";
    "${mod}+shift+x" = "exec betterlockscreen --lock";
    "Caps_L" = "exec --no-startup-id rofi -show drun";
    "Caps_Lock" =
      "exec --no-startup-id exec xdotool key Caps_Lock $HOME/.config/rofi/scripts/launcher_t1";
  };

  workspaceOutputAssign =
    let
      screens = cfg.screen;
      getScreenIndex = i: lib.mod i (builtins.length screens);
      getScreen = i: builtins.elemAt screens (getScreenIndex i);
    in
    builtins.genList
      (i:
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
      command = "xset -dpms";
      always = true;
    }
    {
      command = "xset s noblank";
      always = true;
    }
    {
      command = "xset s off";
      always = true;
    }
    {
      command = "ssh-add ~/.ssh/id_rsa";
      always = true;
    }
    {
      command = "picom --config ~/.config/picom.conf";
      always = true;
    }
    {
      command = "nitrogen --restore";
      always = true;
    }
    {
      command = "libinput-gestures-setup restart";
      always = true;
    }
    {
      command = "setxkbmap -option caps:none";
      always = true;
    }
    { command = "libinput-gestures-setup start"; }
    { command = "xpad"; }
    {
      command =
        "( killall oneko || true ) && oneko -tofocus -position +30+0";
      always = true;
    }
    {
      command =
        "python3 ~/Documents/install/center-mouse/i3-center-mouse.py -a";
      always = true;
    }
    {
      command =
        "/home/dan/.local/bin/ev-cmd --device-path /dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd >> ~/.log/ev-cmd.log";
      always = true;
    }
    {
      command =
        "/home/dan/Documents/rust/logitech-g600-rs/target/debug/logitech-g600-rs --device-path /dev/input/by-id/usb-Logitech_Gaming_Mouse_G600_FED1B7EDC0960017-if01-event-kbd --config-path /home/dan/.config/g600/g600.toml >> ~/.log/g600.log";
      always = true;
    }
    {
      command = "xinput set-prop 10 'libinput Accel Speed' 5";
      always = true;
    }
    {
      command = "xinput set-prop 10 309 1";
      always = true;
    }
    {
      command = "xinput set-prop 10 311 1";
      always = true;
    }
    {
      command = "xinput set-prop 10 317 1";
      always = true;
    }
    {
      command = "xinput set-prop 14 284 1";
      always = true;
    }
    {
      command = "xinput set-prop 15 284 1";
      always = true;
    }
    {
      command = "xinput set-prop 9 295 0";
      always = true;
    }
    {
      command = ''
        xinput | grep -Po "(?<=LingYao ShangHai Thumb Keyboard).*" | grep -Po "(?<=id=)\d+" | xargs -L1 xinput disable'';
      always = true;
    }
    {
      command = ''
        xinput | grep -Po "(?<=Logitech Gaming Mouse G600 Keyboard).*" | grep -Po "(?<=id=)\d+" | xargs -L1 xinput disable'';
      always = true;
    }
    {
      command = "~/.screenlayout/3screen.sh";
      always = true;
    }
    {
      command = "flameshot";
      always = true;
    }
  ];

  focus.followMouse = true;

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
