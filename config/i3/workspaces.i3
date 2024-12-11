# set $layer 1
# set $position left

bindsym $mod+1 exec ~/.local/bin/i3_change.sh position "left" workspace
bindsym $mod+2 exec ~/.local/bin/i3_change.sh position "middle" workspace
bindsym $mod+3 exec ~/.local/bin/i3_change.sh position "right" workspace
 
bindsym $mod+Shift+1 exec ~/.local/bin/i3_change.sh layer 1 "move container to workspace"
bindsym $mod+Shift+2 exec ~/.local/bin/i3_change.sh layer 2 "move container to workspace"
bindsym $mod+Shift+3 exec ~/.local/bin/i3_change.sh layer 3 "move container to workspace"
bindsym $mod+Shift+4 exec ~/.local/bin/i3_change.sh layer 4 "move container to workspace"
bindsym $mod+Shift+5 exec ~/.local/bin/i3_change.sh layer 5 "move container to workspace"
bindsym $mod+Shift+6 exec ~/.local/bin/i3_change.sh layer 6 "move container to workspace"
bindsym $mod+Shift+7 exec ~/.local/bin/i3_change.sh layer 7 "move container to workspace"
bindsym $mod+Shift+8 exec ~/.local/bin/i3_change.sh layer 8 "move container to workspace"
bindsym $mod+Shift+9 exec ~/.local/bin/i3_change.sh layer 9 "move container to workspace"

mode "layer" {
  bindsym $mod+1 exec ~/.local/bin/i3_change.sh layer 1 workspace
  bindsym $mod+2 exec ~/.local/bin/i3_change.sh layer 2 workspace
  bindsym $mod+3 exec ~/.local/bin/i3_change.sh layer 3 workspace
  bindsym $mod+4 exec ~/.local/bin/i3_change.sh layer 4 workspace
  bindsym $mod+5 exec ~/.local/bin/i3_change.sh layer 5 workspace
  bindsym $mod+6 exec ~/.local/bin/i3_change.sh layer 6 workspace
  bindsym $mod+7 exec ~/.local/bin/i3_change.sh layer 7 workspace
  bindsym $mod+8 exec ~/.local/bin/i3_change.sh layer 8 workspace
  bindsym $mod+9 exec ~/.local/bin/i3_change.sh layer 9 workspace

  bindsym Escape mode "default"
  bindsym $mod+r mode "default"
}

bindsym $mod+Tab mode "layer"

set $SCREEN_LEFT "DP-1"
set $SCREEN_CENTER "DP-5"
set $SCREEN_RIGHT "HDMI-0"

workspace 1-left output $SCREEN_LEFT
workspace 1-middle output $SCREEN_CENTER
workspace 1-right output $SCREEN_RIGHT
workspace 2-left output $SCREEN_LEFT
workspace 2-middle output $SCREEN_CENTER
workspace 2-right output $SCREEN_RIGHT
workspace 3-left output $SCREEN_LEFT
workspace 3-middle output $SCREEN_CENTER
workspace 3-right output $SCREEN_RIGHT
workspace 4-left output $SCREEN_LEFT
workspace 4-middle output $SCREEN_CENTER
workspace 4-right output $SCREEN_RIGHT
workspace 5-left output $SCREEN_LEFT
workspace 5-middle output $SCREEN_CENTER
workspace 5-right output $SCREEN_RIGHT
workspace 6-left output $SCREEN_LEFT
workspace 6-middle output $SCREEN_CENTER
workspace 6-right output $SCREEN_RIGHT
workspace 7-left output $SCREEN_LEFT
workspace 7-middle output $SCREEN_CENTER
workspace 7-right output $SCREEN_RIGHT
workspace 8-left output $SCREEN_LEFT
workspace 8-middle output $SCREEN_CENTER
workspace 8-right output $SCREEN_RIGHT
workspace 9-left output $SCREEN_LEFT
workspace 9-middle output $SCREEN_CENTER
workspace 9-right output $SCREEN_RIGHT
