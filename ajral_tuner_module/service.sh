MODDIR=${0%/*}
CONF=/data/adb/ajral_tuner/config.conf

# Terapkan setelan tersimpan sekali saat boot (setelah sistem siap)
( until [ -d /dev/stune ]; do sleep 2; done
  sleep 5
  "$MODDIR/bin/ajral" apply >/dev/null 2>&1

  # Lepas file cache sekali saat boot: RAM langsung lega tanpa membunuh app.
  # Ini aman karena file cache murni bisa dibentuk ulang kapan saja.
  sync
  echo 3 > /proc/sys/vm/drop_caches 2>/dev/null

  # KSM: aktifkan dengan parameter hemat CPU
  if [ "$(cat /sys/kernel/mm/ksm/run 2>/dev/null)" = "1" ]; then
    echo 256 > /sys/kernel/mm/ksm/pages_to_scan 2>/dev/null
    echo 200 > /sys/kernel/mm/ksm/sleep_millisecs 2>/dev/null
  fi
) &

# Trim cache berkala SELAMA layar mati saja (biaya baterai nol, user tidak
# merasakan apa pun). Saat layar menyala proses ini tidak melakukan apa-apa.
( while true; do
    sleep 600
    STATE=$(dumpsys power 2>/dev/null | grep -m1 "mWakefulness=" | cut -d= -f2)
    if [ "$STATE" = "Asleep" ]; then
      # hanya lepas cache bila RAM mulai sesak (di bawah ~2 GB tersedia)
      AVAIL=$(awk '/MemAvailable/{print $2}' /proc/meminfo 2>/dev/null)
      if [ -n "$AVAIL" ] && [ "$AVAIL" -lt 2000000 ]; then
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
      fi
    fi
  done
) &
