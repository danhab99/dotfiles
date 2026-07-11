{
  description = "wireguard";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ../output.nix inputs {
    name = "wireguard";

    options =
      { lib }:
      with lib;
      {
        serverAddress = mkOption {
          type = types.str;
          default = "10.100.0.1/24";
          description = "IP address (with prefix) assigned to the server interface.";
        };

        allowedTCPPorts = mkOption {
          type = types.listOf types.port;
          default = [ ];
          description = "TCP ports reachable from WireGuard clients on the VPN interface.";
        };
      };

    output =
      { pkgs, cfg, lib, ... }:
      let
        interface = "wg0";
        listenPort = 51820;
        privateKeyFile = "/var/lib/wireguard/server.key";
        stateDirectory = "/var/lib/wireguard";
        peersDirectory = "${stateDirectory}/peers";
        clientsDirectory = "${stateDirectory}/clients";
        serverAddressOnly = builtins.head (lib.splitString "/" cfg.serverAddress);
        serverAddressParts = lib.splitString "." serverAddressOnly;
        clientPoolPrefix = lib.concatStringsSep "." (lib.take 3 serverAddressParts);
        localhostRedirectRules = lib.concatMapStringsSep "\n" (
          port:
          let
            p = toString port;
          in
          ''
            iptables -t nat -C PREROUTING -i ${interface} -p tcp --dport ${p} -j REDIRECT --to-ports ${p} 2>/dev/null || \
              iptables -t nat -A PREROUTING -i ${interface} -p tcp --dport ${p} -j REDIRECT --to-ports ${p}
          ''
        ) cfg.allowedTCPPorts;
        dnsLine = "1.1.1.1, 1.0.0.1";
        wgInterfaceService = "wg-quick-${interface}";
        wgOnboard = pkgs.writeShellApplication {
          name = "wg-onboard";
          runtimeInputs = with pkgs; [
            bash
            coreutils
            gnugrep
            gawk
            curl
            iproute2
            wireguard-tools
            qrencode
          ];
          text = ''
            set -euo pipefail

            if [ "$#" -ne 1 ]; then
              echo "usage: wg-onboard <client-name>"
              echo "example: wg-onboard phone1"
              exit 1
            fi

            if [ "$(id -u)" -ne 0 ]; then
              echo "wg-onboard must run as root because it writes /var/lib/wireguard and updates wg peers"
              echo "run: sudo wg-onboard $1"
              exit 1
            fi

            NAME="$1"
            IFACE="${interface}"
            STATE_DIR="${stateDirectory}"
            PEERS_DIR="${peersDirectory}"
            CLIENTS_DIR="${clientsDirectory}"
            ENDPOINT_OVERRIDE_FILE="$STATE_DIR/public-endpoint"
            SERVER_PUB="$STATE_DIR/server.pub"
            SERVER_KEY="${privateKeyFile}"

            if ! echo "$NAME" | grep -Eq '^[a-zA-Z0-9_.-]+$'; then
              echo "client-name may only contain: a-z A-Z 0-9 _ . -"
              exit 1
            fi

            ENDPOINT_HOST=""
            if [ -s "$ENDPOINT_OVERRIDE_FILE" ]; then
              ENDPOINT_HOST="$(tr -d '[:space:]' < "$ENDPOINT_OVERRIDE_FILE")"
            fi

            if [ -z "$ENDPOINT_HOST" ]; then
              ENDPOINT_HOST="$(curl -4fsS --max-time 5 https://api.ipify.org || true)"
            fi

            if [ -z "$ENDPOINT_HOST" ]; then
              ENDPOINT_HOST="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1;i<=NF;i++) if ($i=="src") { print $(i+1); exit }}')"
            fi

            if [ -z "$ENDPOINT_HOST" ]; then
              echo "unable to determine endpoint host automatically"
              echo "set one manually by writing host/ip to $ENDPOINT_OVERRIDE_FILE"
              exit 1
            fi

            ENDPOINT="$ENDPOINT_HOST:${toString listenPort}"

            mkdir -p "$STATE_DIR" "$PEERS_DIR" "$CLIENTS_DIR" "$STATE_DIR/qrcodes"
            umask 077

            if [ ! -s "$SERVER_KEY" ]; then
              wg genkey > "$SERVER_KEY"
              chmod 600 "$SERVER_KEY"
            fi

            if [ ! -s "$SERVER_PUB" ]; then
              cat "$SERVER_KEY" | wg pubkey > "$SERVER_PUB"
              chmod 644 "$SERVER_PUB"
            fi

            if [ ! -s "$SERVER_PUB" ]; then
              echo "failed to initialize server public key: $SERVER_PUB"
              exit 1
            fi

            USED_IPS="$(
              [ -d "$PEERS_DIR" ] && grep -hE '^ALLOWED_IPS=' "$PEERS_DIR"/*.env 2>/dev/null | sed -E 's/^ALLOWED_IPS=([^/]+)\/32$/\1/' || true
            )"

            CLIENT_IP=""
            for i in $(seq 2 254); do
              CANDIDATE="${clientPoolPrefix}.$i"
              if ! echo "$USED_IPS" | grep -qx "$CANDIDATE"; then
                CLIENT_IP="$CANDIDATE"
                break
              fi
            done

            if [ -z "$CLIENT_IP" ]; then
              echo "unable to allocate client IP automatically; provide one explicitly"
              exit 1
            fi

            CLIENT_DIR="$CLIENTS_DIR/$NAME"
            mkdir -p "$CLIENT_DIR"

            CLIENT_PRIV="$CLIENT_DIR/private.key"
            CLIENT_PUB="$CLIENT_DIR/public.key"
            CLIENT_PSK="$CLIENT_DIR/preshared.key"
            CLIENT_CONF="$CLIENT_DIR/${interface}.conf"
            PEER_FILE="$PEERS_DIR/$NAME.env"

            if [ -f "$PEER_FILE" ]; then
              echo "peer already exists: $PEER_FILE"
              exit 1
            fi

            wg genkey > "$CLIENT_PRIV"
            cat "$CLIENT_PRIV" | wg pubkey > "$CLIENT_PUB"
            wg genpsk > "$CLIENT_PSK"

            CLIENT_PUBLIC_KEY="$(cat "$CLIENT_PUB")"
            SERVER_PUBLIC_KEY="$(cat "$SERVER_PUB")"

            cat > "$PEER_FILE" <<EOF
            PUBLIC_KEY=$CLIENT_PUBLIC_KEY
            PRESHARED_KEY_FILE=$CLIENT_PSK
            ALLOWED_IPS=$CLIENT_IP/32
            EOF

            cat > "$CLIENT_CONF" <<EOF
            [Interface]
            PrivateKey = $(cat "$CLIENT_PRIV")
            Address = $CLIENT_IP/32
            DNS = ${dnsLine}

            [Peer]
            PublicKey = $SERVER_PUBLIC_KEY
            PresharedKey = $(cat "$CLIENT_PSK")
            Endpoint = $ENDPOINT
            AllowedIPs = 0.0.0.0/0, ::/0
            PersistentKeepalive = 25
            EOF

            if wg show "$IFACE" >/dev/null 2>&1; then
              wg set "$IFACE" peer "$CLIENT_PUBLIC_KEY" preshared-key "$CLIENT_PSK" allowed-ips "$CLIENT_IP/32"
            else
              echo "warning: interface $IFACE is down; peer saved and will be restored on next start"
            fi

            chmod 600 "$CLIENT_PRIV" "$CLIENT_PSK" "$CLIENT_CONF" "$PEER_FILE"
            chmod 644 "$CLIENT_PUB"

            QR_TXT="$STATE_DIR/qrcodes/$NAME.txt"
            QR_PNG="$STATE_DIR/qrcodes/$NAME.png"
            cp "$CLIENT_CONF" "$QR_TXT"
            qrencode -t ansiutf8 < "$CLIENT_CONF"
            qrencode -o "$QR_PNG" < "$CLIENT_CONF"

            echo ""
            echo "Client provisioned: $NAME"
            echo "Config path: $CLIENT_CONF"
            echo "QR image path: $QR_PNG"
            echo "Import into any WireGuard client by scanning terminal QR or opening $QR_PNG"
          '';
        };
        wgOnboardAndroidCompat = pkgs.writeShellApplication {
          name = "wg-onboard-android";
          runtimeInputs = with pkgs; [ wgOnboard ];
          text = ''
            exec wg-onboard "$@"
          '';
        };
      in
      {
        packages = with pkgs; [
          wireguard-tools
          qrencode # used by wg-new-user.sh for QR code output
          wgOnboard
          wgOnboardAndroidCompat
        ];

        nixos = {
          # Enable IP forwarding so VPN clients can reach the LAN / internet.
          boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

          # Persist all generated WireGuard material outside the Git repo.
          systemd.tmpfiles.rules = [
            "d ${stateDirectory} 0700 root root -"
            "d ${peersDirectory} 0700 root root -"
            "d ${clientsDirectory} 0700 root root -"
            "d ${stateDirectory}/qrcodes 0700 root root -"
          ];

          networking.firewall = {
            allowedUDPPorts = [ listenPort ];
            trustedInterfaces = [ interface ];
            interfaces.${interface}.allowedTCPPorts = cfg.allowedTCPPorts;
          };

          networking.wg-quick.interfaces.${interface} = {
            address = [ cfg.serverAddress ];
            listenPort = listenPort;
            privateKeyFile = privateKeyFile;
          };

          # Generate key material once and then keep reusing persisted files.
          systemd.services.${wgInterfaceService}.preStart = ''
            set -eu
            umask 077

            mkdir -p "${stateDirectory}" "${peersDirectory}" "${clientsDirectory}" "${stateDirectory}/qrcodes"

            if [ ! -s "${privateKeyFile}" ]; then
              ${pkgs.wireguard-tools}/bin/wg genkey > "${privateKeyFile}"
            fi

            chmod 600 "${privateKeyFile}"

            ${pkgs.coreutils}/bin/cat "${privateKeyFile}" | ${pkgs.wireguard-tools}/bin/wg pubkey > "${stateDirectory}/server.pub"
            chmod 644 "${stateDirectory}/server.pub"
          '';

          # Re-apply peers saved out-of-band so clients survive reboots and switches.
          systemd.services."wireguard-restore-peers-${interface}" = {
            description = "Restore persisted WireGuard peers for ${interface}";
            wantedBy = [ "multi-user.target" ];
            after = [ "${wgInterfaceService}.service" ];
            requires = [ "${wgInterfaceService}.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = with pkgs; [
              bash
              coreutils
              gnugrep
              wireguard-tools
            ];
            script = ''
              set -euo pipefail
              shopt -s nullglob

              PEER_FILES=("${peersDirectory}"/*.env)

              for peer_file in "''${PEER_FILES[@]}"; do
                unset PUBLIC_KEY PRESHARED_KEY_FILE ALLOWED_IPS
                # shellcheck disable=SC1090
                source "$peer_file"

                if [ -n "''${PUBLIC_KEY:-}" ] && [ -n "''${PRESHARED_KEY_FILE:-}" ] && [ -n "''${ALLOWED_IPS:-}" ] && [ -f "$PRESHARED_KEY_FILE" ]; then
                  wg set "${interface}" peer "$PUBLIC_KEY" preshared-key "$PRESHARED_KEY_FILE" allowed-ips "$ALLOWED_IPS"
                fi
              done
            '';
          };

          # Automatic NAT setup based on the current default route interface.
          systemd.services."wireguard-nat-${interface}" = {
            description = "Enable NAT forwarding for ${interface}";
            wantedBy = [ "multi-user.target" ];
            after = [ "${wgInterfaceService}.service" ];
            requires = [ "${wgInterfaceService}.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = with pkgs; [
              bash
              iproute2
              gawk
              iptables
            ];
            script = ''
              set -euo pipefail

              EXT_IF="$(ip -4 route list default | awk 'NR==1 { print $5 }')"

              if [ -z "$EXT_IF" ]; then
                echo "no default route interface found; skipping NAT setup"
                exit 0
              fi

              iptables -t nat -C POSTROUTING -s ${cfg.serverAddress} -o "$EXT_IF" -j MASQUERADE 2>/dev/null || \
                iptables -t nat -A POSTROUTING -s ${cfg.serverAddress} -o "$EXT_IF" -j MASQUERADE

              iptables -C FORWARD -i ${interface} -j ACCEPT 2>/dev/null || \
                iptables -A FORWARD -i ${interface} -j ACCEPT

              iptables -C FORWARD -o ${interface} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
                iptables -A FORWARD -o ${interface} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
            '';
          };

          # Make localhost-bound services reachable from WireGuard clients via
          # the server VPN address (e.g. 10.100.0.1:<port> -> 127.0.0.1:<port>).
          systemd.services."wireguard-localhost-redirect-${interface}" = {
            description = "Redirect WireGuard TCP ports to localhost on ${interface}";
            wantedBy = [ "multi-user.target" ];
            after = [ "${wgInterfaceService}.service" ];
            requires = [ "${wgInterfaceService}.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            path = with pkgs; [
              bash
              iptables
            ];
            script = ''
              set -euo pipefail

              ${localhostRedirectRules}
            '';
          };
        };
      };
  };
}
