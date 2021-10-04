function type() {
  xdotool type --delay 5 "$1"
}

function enter() {
  # sleep 0.01
  xdotool key Enter
}

rm /tmp/target
type "0f:hv0y:tabnew /tmp/target"
enter
type "p:wq"
enter

rm /tmp/line
type "0f:f:hvF:ly:tabnew /tmp/line"
enter
type "p:wq"
enter

xdotool key Super_L+Enter

sleep 0.1
type "vim +"
type $(cat /tmp/line)
type " \""
type $(cat /tmp/target)
type "\""
enter
type "zz"

