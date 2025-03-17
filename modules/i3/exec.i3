exec_always xset -dpms
exec_always xset s noblank
exec_always xset s off
exec_always ssh-add ~/.ssh/id_rsa
exec_always picom --config ~/.config/picom.conf 
exec_always nitrogen --restore
exec_always libinput-gestures-setup restart
