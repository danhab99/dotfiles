exec --no-startup-id libinput-gestures-setup start
exec xpad
exec_always ( killall oneko || true ) && oneko -tofocus -position +30+0
exec_always --no-startup-id python3 ~/Documents/install/center-mouse/i3-center-mouse.py -a
exec_always killall ev-cmd || /home/dan/.local/bin/ev-cmd --device-path /dev/input/by-id/usb-LingYao_ShangHai_Thumb_Keyboard_081820131130-event-kbd >> ~/.log/ev-cmd.log
exec_always killall logitech-g600-rs || /home/dan/.local/bin/logitech-g600-rs --device-path /dev/input/by-id/usb-Logitech_Gaming_Mouse_G600_FED1B7EDC0960017-if01-event-kbd --config-path /home/dan/.config/g600/g600.toml >> ~/.log/g600.log
exec_always xinput set-prop 10 'libinput Accel Speed' 5
exec_always xinput set-prop 10 309 1
exec_always xinput set-prop 10 311 1
exec_always xinput set-prop 10 317 1
exec_always xinput set-prop 14 284 1
exec_always xinput set-prop 15 284 1
exec_always xinput set-prop 9 295 0
exec_always xinput | grep -Po "(?<=LingYao ShangHai Thumb Keyboard).*" | grep -Po "(?<=id=)\d+" | xargs -L1 xinput disable
exec_always xinput | grep -Po "(?<=Logitech Gaming Mouse G600 Keyboard).*" | grep -Po "(?<=id=)\d+" | xargs -L1 xinput disable
exec_always ~/.screenlayout/3screen.sh
