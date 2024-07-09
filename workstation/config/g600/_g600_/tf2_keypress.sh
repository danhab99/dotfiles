function sleep_key() {
  echo "Keypress $3"
  xdotool key $3
  RAND=$(shuf -i $1-$2 -n 1)
  RAND=$(echo "$RAND / 1000.0" | bc -l)
  echo "Sleep $RAND"
  sleep $RAND
}
