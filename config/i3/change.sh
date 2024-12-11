set +x
mkdir -p /tmp/.i3vars/

echo $2 > /tmp/.i3vars/$1

layer=$(cat /tmp/.i3vars/layer 2>/dev/null || echo "1")
position=$(cat /tmp/.i3vars/position 2>/dev/null || echo "middle")

echo "$3 $layer-$position"

i3-msg $3 "$layer-$position"
i3-msg mode "default"
