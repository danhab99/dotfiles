#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <username>"
  exit 1
fi

USER="$1"
WG_IF="wg0"
WG_NET="10.100.0"
WG_SERVER_IP="10.100.0.1"
WG_PORT="51820"
WG_DIR="/etc/wireguard/users"

SERVER_PUBKEY="$(wg show $WG_IF public-key)"
SERVER_ENDPOINT="70.23.207.166:$WG_PORT"

mkdir -p "$WG_DIR"
umask 077

PRIV="$WG_DIR/$USER.key"
PUB="$WG_DIR/$USER.pub"
CONF="$WG_DIR/$USER.conf"

if [ -e "$PRIV" ]; then
  echo "Error: user '$USER' already exists"
  exit 1
fi

# Find next free IP
USED_IPS=$(wg show $WG_IF allowed-ips | awk '{print $2}' | cut -d/ -f1)
for i in $(seq 2 254); do
  IP="$WG_NET.$i"
  if ! echo "$USED_IPS" | grep -qx "$IP"; then
    CLIENT_IP="$IP"
    break
  fi
done

if [ -z "${CLIENT_IP:-}" ]; then
  echo "No free IPs available"
  exit 1
fi

# Generate keys
wg genkey | tee "$PRIV" | wg pubkey > "$PUB"

# Add peer LIVE
wg set "$WG_IF" peer "$(cat "$PUB")" allowed-ips "$CLIENT_IP/32"

# Generate client config
cat > "$CONF" <<EOF
[Interface]
PrivateKey = $(cat "$PRIV")
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 10.100.0.0/24
PersistentKeepalive = 25
EOF

echo
echo "✔ User '$USER' added"
echo "  IP: $CLIENT_IP"
echo "  Config: $CONF"
echo
echo "=== QR CODE (scan with Android WireGuard app) ==="
qrencode -t ansiutf8 < "$CONF"
