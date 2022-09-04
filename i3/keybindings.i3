bindsym $mod+Return exec urxvt
bindsym $mod+Ctrl+Return exec rm /tmp/workdir && urxvt
bindsym $mod+Shift+Return exec urxvt -e ssh mac
bindsym $mod+q kill

# change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# Move workspace between screens
bindsym $mod+Ctrl+Left move workspace to output left
bindsym $mod+Ctrl+Right move workspace to output right
bindsym $mod+Ctrl+h move workspace to output left
bindsym $mod+Ctrl+l move workspace to output right

# move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in vertical orientation
bindsym $mod+v split toggle

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# focus the parent container
bindsym $mod+a focus parent
