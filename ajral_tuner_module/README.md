# AjralDEV Kernel Tuner

A KernelSU Next WebUI module that tunes the **AjralDEV Kernel** (`4.19.113-AjralDEV-Kernel`) at runtime — no kernel rebuild, no companion app. Every value is written through sysfs/procfs, persisted to disk, and re-applied on every boot.

<p align="center">
  <img alt="KernelSU Next" src="https://img.shields.io/badge/KernelSU_Next-v3.4.0--legacy-22c55e?style=flat-square">
  <img alt="Kernel" src="https://img.shields.io/badge/kernel-4.19.113-0ea5e9?style=flat-square">
  <img alt="Device" src="https://img.shields.io/badge/device-c2q_%2F_SM--N986N-6366f1?style=flat-square">
  <img alt="License" src="https://img.shields.io/badge/license-GPL--2.0-f59e0b?style=flat-square">
</p>

---

## Features

### Profiles

Four one-tap presets that write a whole set of values at once (CPU, GPU, memory, I/O):

| Profile | Governors | CPU limit | GPU max pwrlevel | swappiness | sched_boost | stune_top |
|:--|:--|--:|:--:|--:|--:|--:|
| 🔋 **Battery** | schedutil | 1,804,800 | 3 | 100 | 0 | 1 |
| ⚖️ **Balanced** | schedutil | unlimited | 0 | 130 | 1 | 5 |
| 🎮 **Game** | schedutil | unlimited | 0 | 100 | 2 | 8 |
| 🚀 **Performance** | performance | unlimited | 0 | 160 | 2 | 10 |

`Game` keeps `schedutil` so clocks drop between frames instead of pinning every core at maximum — high FPS without the sustained heat of the `Performance` profile.

### Tuning panels

| Panel | Controls |
|:--|:--|
| **BORE scheduler** | enable/disable, penalty scale, penalty offset, smoothness long/short, cache lifetime, fork atavistic |
| **CPU** | global max frequency limit, governor per cluster (0–3 / 4–6 / 7), `sched_boost`, `schedtune.top-app` |
| **GPU** | governor, max power level (0 = highest, 6 = most efficient) |
| **Memory** | swappiness, vfs cache pressure, `min_free_kbytes`, KSM |
| **I/O** | scheduler for UFS (`sda`) and SD card (`mmcblk0`), SD read-ahead |
| **Network** | TCP congestion control |

### Monitoring

- Live temperatures: battery, CPU prime / big, GPU — colour-coded (green <45 °C, amber 45–55 °C, red >55 °C)
- Free RAM and load average with a progress bar
- Top CPU consumers list, refreshed every 30 s while the card is open and the tab is visible

Polling pauses automatically when the page is hidden or another tab is open, so the WebUI does not heat the device by itself.

---

## Install

1. Install **KernelSU Next** and flash a compatible kernel (see the [kernel repository](https://github.com/JackRipper-ID/AjralDEV-Kernel-c2q)).
2. Download `AjralTuner-ksu-module.zip` from the [releases page](../../releases/latest).
3. In KernelSU Next → **Modules** → **Install from storage** → pick the zip.
4. Reboot, or press **Apply** in the WebUI to activate immediately.

The module installs to `/data/adb/modules/ajral_tuner/`. Config lives in `/data/adb/ajral_tuner/config.conf` and survives module updates.

---

## How it works

```text
WebUI (index.html)
   │  ksu.exec(cmd, opts, callback)
   ▼
bin/ajral                 # shell engine: info | set | apply | profile | reset
   │  wr() / rd()          # sysfs + procfs read/write helpers
   ▼
sysfs / procfs nodes  ◄──  service.sh re-applies config.conf at every boot
```

`bin/ajral` accepts a whitelist of keys and refuses anything else, so a typo in the UI cannot write to an arbitrary path.

```bash
su -c "sh /data/adb/modules/ajral_tuner/bin/ajral info"
su -c "sh /data/adb/modules/ajral_tuner/bin/ajral set swappiness 130"
su -c "sh /data/adb/modules/ajral_tuner/bin/ajral profile game"
su -c "sh /data/adb/modules/ajral_tuner/bin/ajral reset"
```

---

## Device-specific notes

Built and verified on a **Galaxy Note20 Ultra 5G Snapdragon** (`c2q` / SM-N986N, Android 13, One UI 5.1.1). Several controls that exist upstream are deliberately **not** exposed, because they do not work on this hardware:

| Limitation | Reason |
|:--|:--|
| **CPU max frequency per cluster** | `scaling_max_freq` is read-only here; the kernel accepts only the global `/sys/power/cpufreq_max_limit` |
| **CPU minimum frequency** | Samsung's power HAL reverts it, and `cpufreq_min_limit` is writable but has no effect |
| **UFS read-ahead** | reverted by the power HAL; only the SD card read-ahead is exposed |
| **I/O schedulers** | `sda` supports only `noop` / `deadline` / `cfq`, so profiles use `deadline` for UFS and `bfq` for the SD card |

Battery temperature is reported in 0.1 °C units, while thermal zones use milli-°C — the UI detects the scale automatically.

---

## Uninstall

Remove the module in KernelSU Next and reboot. The module does not modify any system partition and touches no file outside `/data/adb/ajral_tuner/`.

Settings that were written to the kernel are reset by the next reboot once the module is gone, since nothing re-applies them.

---

## License

GPL-2.0, matching the kernel it tunes.
