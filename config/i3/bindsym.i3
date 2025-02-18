bindsym Pause exec /home/dan/.config/i3/lock.sh
bindsym XF86AudioLowerVolume exec amixer sset Master 5%-
bindsym XF86AudioRaiseVolume exec amixer sset Master 5%+
bindsym XF86AudioMute exec amixer sset Master toggle
bindsym XF86AudioMicMute exec amixer sset Capture toggle
bindsym XF86MonBrightnessUp exec xbacklight -inc 10 # increase screen brightness
bindsym XF86MonBrightnessDown exec xbacklight -dec 10 # decrease screen brightness
bindsym $mod+p exec $HOME/.config/rofi/applets/android/screenshot.sh
bindsym $mod+w exec brave 
bindsym $mod+e exec nemo
bindsym $mod+plus gaps inner all minus 2
bindsym $mod+minus gaps inner all plus 2
bindsym --release Caps_Lock exec pkill -SIGRTMIN+11 i3blocks
bindsym --release Num_Lock  exec pkill -SIGRTMIN+11 i3blocks
bindsym $mod+period exec pacmd set-default-sink alsa_output.usb-SAVITECH_Bravo-X_USB_Audio-01.analog-stereo
bindsym $mod+comma exec pacmd set-default-sink alsa_output.pci-0000_00_14.2.analog-stereo
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86AudioStop exec playerctl stop
bindsym $mod+question exec i3help
bindsym --release $mod+ctrl+V exec ~/Documents/dotfiles/vgrep.x11.sh
bindsym $mod+s exec sleep 0.1 && xdotool type "¯\_(ツ)_/¯"
bindsym $mod+Mod1+h exec xdotool mousemove_relative -p 270 10
bindsym $mod+Mod1+l exec xdotool mousemove_relative -p 90 10
bindsym $mod+Mod1+k exec xdotool mousemove_relative -p 0 10
bindsym $mod+Mod1+j exec xdotool mousemove_relative -p 180 10
bindsym $mod+Shift+Mod1+h exec xdotool mousemove_relative -p 270 100
bindsym $mod+Shift+Mod1+l exec xdotool mousemove_relative -p 90 100
bindsym $mod+Shift+Mod1+k exec xdotool mousemove_relative -p 0 100
bindsym $mod+Shift+Mod1+j exec xdotool mousemove_relative -p 180 100
bindsym $mod+Mod1+c exec xdotool mousedown 1 && xdotool mouseup 1
bindsym XF86Display exec arandr
bindsym XF86Messenger exec xpad -n
bindsym $mod+n exec xpad -n
bindsym $mod+c exec kcalc
bindsym $mod+Shift+Ctrl+l exec sleep 0.5 && xdotool type https://www.linkedin.com/in/danhabot/
bindsym $mod+Ctrl+g exec sleep 0.5 && xdotool type https://github.com/danhab99
bindsym $mod+Ctrl+e exec sleep 0.5 && xdotool type dan.habot@gmail.com
bindsym $mod+Ctrl+a exec playerctl previous
bindsym $mod+Ctrl+d exec playerctl next
bindsym $mod+Ctrl+w exec amixer sset Master 5%+
bindsym $mod+Ctrl+s exec amixer sset Master 5%-

