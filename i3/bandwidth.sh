INTERFACE=wlp3s0

CURRENT_TX=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes)
CURRENT_RX=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes)

PAST_TX=-1
PAST_RX=-1

if test -f "/tmp/txl"; then
  PAST_TX=$(cat /tmp/txl)
fi

if test -f "/tmp/rxl"; then
  PAST_RX=$(cat /tmp/rxl)
fi

echo $CURRENT_TX >/tmp/txl
echo $CURRENT_RX >/tmp/rxl

if ((PAST_RX < 0 || PAST_TX < 0)); then
  exit 1
fi

let "DIFF_TX = $CURRENT_TX - $PAST_TX"
let "DIFF_RX = $CURRENT_RX - $PAST_RX"

P_TX=$(numfmt --to=iec --suffix=B --format="%.0f" $DIFF_TX)
P_RX=$(numfmt --to=iec --suffix=B --format="%.0f" $DIFF_RX)

echo "IN $P_RX OUT $P_TX"
