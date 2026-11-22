MODDIR=${0%/*}

# Terapkan setelan tersimpan sekali saat boot (setelah sistem siap)
( until [ -d /dev/stune ]; do sleep 2; done
  sleep 5
  "$MODDIR/bin/ajral" apply >/dev/null 2>&1
) &
