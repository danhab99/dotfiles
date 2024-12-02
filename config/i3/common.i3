
set $bg-color 	         #2f343f
set $bg-color-t          #2f343f00
set $inactive-bg-color   #2f343f00
set $inactive-text-color #676E7D
set $indicator-color     #333333
set $mod Mod4
set $text-color          #f3f4f5
set $urgent-bg-color     #E53935
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

mode "resize" {
        set $SIZE_STEP 5
        bindsym h resize shrink width $SIZE_STEP px or $SIZE_STEP ppt
        bindsym j resize grow height $SIZE_STEP px or $SIZE_STEP ppt
        bindsym k resize shrink height $SIZE_STEP px or $SIZE_STEP ppt
        bindsym l resize grow width $SIZE_STEP px or $SIZE_STEP ppt

        bindsym Left resize shrink width $SIZE_STEP px or $SIZE_STEP ppt
        bindsym Down resize grow height $SIZE_STEP px or $SIZE_STEP ppt
        bindsym Up resize shrink height $SIZE_STEP px or $SIZE_STEP ppt
        bindsym Right resize grow width $SIZE_STEP px or $SIZE_STEP ppt

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}


bar {
  status_command i3blocks -c ~/.config/i3/i3blocks.conf
	i3bar_command i3bar -t 
	position bottom
	colors {
		background $bg-color-t
    separator $text-color
		#                  border             background         text
		focused_workspace  $bg-color          $bg-color          $text-color
		inactive_workspace $inactive-bg-color $inactive-bg-color $inactive-text-color
		urgent_workspace   $urgent-bg-color   $urgent-bg-color   $text-color
	}
}


font pango:monospace 12

for_window [class="^.*"] border pixel 0
for_window [class="hl2_linux"] fullscreen enable
for_window [class="xpad" instance="xpad"] floating enable
for_window [title="Android Emulator"] floating enable
for_window [window_role="pop-up"] floating enable
for_window [window_role="pop-up"] resize set 600 500

border_radius 8

client.focused          $bg-color           $bg-color          $text-color          $indicator-color
client.focused_inactive $inactive-bg-color $inactive-bg-color $inactive-text-color $indicator-color
client.unfocused        $inactive-bg-color $inactive-bg-color $inactive-text-color $indicator-color
client.urgent           $urgent-bg-color    $urgent-bg-color   $text-color          $indicator-color


bindsym $mod+0 workspace $ws10
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6
bindsym $mod+7 workspace $ws7
bindsym $mod+8 workspace $ws8
bindsym $mod+9 workspace $ws9
bindsym $mod+Ctrl+Return exec rm /tmp/workdir && urxvt
bindsym $mod+Ctrl+a exec playerctl previous
bindsym $mod+Ctrl+d exec playerctl next
bindsym $mod+Ctrl+e exec sleep 0.5 && xdotool type dan.habot@gmail.com
bindsym $mod+Ctrl+g exec sleep 0.5 && xdotool type https://github.com/danhab99
bindsym $mod+Ctrl+s exec amixer sset Master 5%-
bindsym $mod+Ctrl+w exec amixer sset Master 5%+
bindsym $mod+Down focus down
bindsym $mod+Left focus left
bindsym $mod+Mod1+c exec xdotool mousedown 1 && xdotool mouseup 1
bindsym $mod+Mod1+h exec xdotool mousemove_relative -p 270 10
bindsym $mod+Mod1+j exec xdotool mousemove_relative -p 180 10
bindsym $mod+Mod1+k exec xdotool mousemove_relative -p 0 10
bindsym $mod+Mod1+l exec xdotool mousemove_relative -p 90 10
bindsym $mod+Return exec urxvt
bindsym $mod+Right focus right
bindsym $mod+Shift+0 move container to workspace $ws10
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6
bindsym $mod+Shift+7 move container to workspace $ws7
bindsym $mod+Shift+8 move container to workspace $ws8
bindsym $mod+Shift+9 move container to workspace $ws9
bindsym $mod+Shift+Ctrl+l exec sleep 0.5 && xdotool type https://www.linkedin.com/in/danhabot/
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Mod1+h exec xdotool mousemove_relative -p 270 100
bindsym $mod+Shift+Mod1+j exec xdotool mousemove_relative -p 180 100
bindsym $mod+Shift+Mod1+k exec xdotool mousemove_relative -p 0 100
bindsym $mod+Shift+Mod1+l exec xdotool mousemove_relative -p 90 100
bindsym $mod+Shift+Return exec urxvt -e ssh -XY remotestation
bindsym $mod+Shift+Right move right
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right
bindsym $mod+Shift+r restart
bindsym $mod+Shift+space floating toggle
bindsym $mod+Tab exec $HOME/.config/rofi/launchers/misc/launch_windows.sh
bindsym $mod+Up focus up
bindsym $mod+a focus parent
bindsym $mod+c exec deepin-calculator
bindsym $mod+comma exec pacmd set-default-sink alsa_output.pci-0000_00_14.2.analog-stereo
bindsym $mod+d exec $HOME/.config/rofi/launchers/misc/launch_drun.sh
bindsym $mod+e exec nemo
bindsym $mod+f fullscreen toggle
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+minus gaps inner all plus 2
bindsym $mod+n exec xpad -n
bindsym $mod+p exec $HOME/.config/rofi/applets/android/screenshot.sh
bindsym $mod+period exec pacmd set-default-sink alsa_output.usb-SAVITECH_Bravo-X_USB_Audio-01.analog-stereo
bindsym $mod+plus gaps inner all minus 2
bindsym $mod+q kill
bindsym $mod+question exec i3help
bindsym $mod+r mode "resize"
bindsym $mod+s exec sleep 0.1 && xdotool type "¯\_(ツ)_/¯"
bindsym $mod+shift+x exec i3lock -c 000000
bindsym $mod+space focus mode_toggle
bindsym $mod+v split toggle
bindsym $mod+w exec brave 
bindsym --release $mod+ctrl+V exec ~/Documents/dotfiles/vgrep.x11.sh
bindsym --release Caps_Lock exec pkill -SIGRTMIN+11 i3blocks
bindsym --release Num_Lock  exec pkill -SIGRTMIN+11 i3blocks
bindsym Pause exec /home/dan/.config/i3/lock.sh
bindsym XF86AudioLowerVolume exec amixer sset Master 5%-
bindsym XF86AudioMicMute exec amixer sset Capture toggle
bindsym XF86AudioMute exec amixer sset Master toggle
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86AudioRaiseVolume exec amixer sset Master 5%+
bindsym XF86AudioStop exec playerctl stop
bindsym XF86Display exec arandr
bindsym XF86Messenger exec xpad -n
bindsym XF86MonBrightnessDown exec xbacklight -dec 10 # decrease screen brightness
bindsym XF86MonBrightnessUp exec xbacklight -inc 10 # increase screen brightness
