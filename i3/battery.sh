while true; do
  CHARGE_PERCENT=$(acpi | grep -Po "\d+%" | grep -Po "\d+")
  echo $CHARGE_PERCENT

  if [ $CHARGE_PERCENT -lt "10" ]; then
    abeep -f 1000 -l 80
    sleep 0.05
    abeep -f 1000 -l 80
    sleep 0.05
    abeep -f 1000 -l 80
    sleep 0.05
  fi
  sleep 5
done
