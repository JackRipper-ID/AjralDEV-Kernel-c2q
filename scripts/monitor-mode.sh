#!/system/bin/sh
# Put a USB Wi-Fi adapter into monitor mode on c2q (AjralDEV Kernel 4.19.113).
#
# Usage (from Android shell, as root):
#   sh monitor-mode.sh wlan1 up
#   sh monitor-mode.sh wlan1 down
#
# Or from inside the Debian chroot:
#   export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#   sh monitor-mode.sh wlan1 up

IFACE="${1:-wlan1}"
ACTION="${2:-up}"

if [ "$ACTION" = "down" ]; then
  ip link set "$IFACE" down 2>/dev/null
  iw dev "$IFACE" set type managed 2>/dev/null
  ip link set "$IFACE" up 2>/dev/null
  iw dev "$IFACE" info
  exit 0
fi

if ! ip link show "$IFACE" >/dev/null 2>&1; then
  echo "[!] $IFACE not present. Available interfaces:"
  iw dev 2>/dev/null | grep Interface || ip -br link
  exit 1
fi

pkill -f "wpa_supplicant.*$IFACE" 2>/dev/null

ip link set "$IFACE" down
iw dev "$IFACE" set type monitor || { echo "[!] failed to set monitor mode"; exit 1; }
ip link set "$IFACE" up
iw dev "$IFACE" set channel "${CHANNEL:-1}" 2>/dev/null || true

iw dev "$IFACE" info
echo "[+] $IFACE is now in monitor mode."
