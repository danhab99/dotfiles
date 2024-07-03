if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload example --config=$HOME/.config/polybar/config & 
  done
else
  polybar --reload example &
fi
