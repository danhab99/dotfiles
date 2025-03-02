exec --no-startup-id libinput-gestures-setup start
exec xpad
exec_always ( killall oneko || true ) && oneko -tofocus -position +30+0
exec_always --no-startup-id python3 ~/Documents/install/center-mouse/i3-center-mouse.py -a

exec_always xinput set-prop $(xinput list --id-only 'SynPS/2 Synaptics TouchPad') 336 1
exec_always xinput set-prop $(xinput list --id-only 'SynPS/2 Synaptics TouchPad') 309 1
exec_always xinput set-prop $(xinput list --id-only 'SynPS/2 Synaptics TouchPad') 311 1
exec_always xinput set-prop $(xinput list --id-only 'SynPS/2 Synaptics TouchPad') 317 1
exec_always xinput set-prop $(xinput list --id-only 'SynPS/2 Synaptics TouchPad') 'libinput Accel Speed' 0.8


bindsym XF86AudioLowerVolume exec amixer -D pulse sset Master 5%-
bindsym XF86AudioRaiseVolume exec amixer -D pulse sset Master 5%+
bindsym XF86AudioMute exec amixer -D pulse sset Master toggle
bindsym XF86AudioMicMute exec amixer -D pulse sset Capture toggle

# Sreen brightness controls
bindsym XF86MonBrightnessUp exec xbacklight -inc 10 # increase screen brightness
bindsym XF86MonBrightnessDown exec xbacklight -dec 10 # decrease screen brightness

bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous
bindsym XF86AudioStop exec playerctl stop

