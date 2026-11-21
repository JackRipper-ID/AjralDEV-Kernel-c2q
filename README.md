# AjralDEV Kernel — Samsung Galaxy Note20 Ultra 5G (Snapdragon) `c2q`

Custom Linux **4.19.113** kernel for the Samsung Galaxy Note20 Ultra 5G Snapdragon variant
(`c2q` / `c2qksw` / SM-N986N), Android 13 / One UI 5.1.1.

This build combines two feature sets that normally require flashing two different kernels:

* **KernelSU Next** (root manager) — working alongside Magisk in the same ramdisk
* **NetHunter** — `MAC80211` stack plus nine built-in USB Wi-Fi drivers for monitor mode / packet injection

Both live in a **single kernel image**, so there is no more flashing back and forth.

---

## Why this kernel exists

The device is **A-only** (`is_slot_device=0`): there is exactly one boot partition
(`/dev/block/sda23`). Two kernels cannot coexist. Previously the choices were:

| Kernel | KernelSU Next | Wi-Fi monitor | Storage tuning |
|---|---|---|---|
| `4.19.325-AjralDEV` (v7.1) | ✅ | ❌ (`MAC80211` not set) | BFQ compiled, CFQ default |
| `4.19.113` (old NetHunter build) | ❌ (`CONFIG_KSU` not set) | ✅ | no BFQ |
| **This build** | ✅ | ✅ | BFQ + WBT enabled |

---

## Image details

```
Linux version 4.19.113 (ajraldev@Killer) (clang version 10.0.6 for Android NDK)
#1 SMP PREEMPT Fri Nov 20 20:49:25 WIB 2026
```

| Artifact | Size | SHA-256 |
|---|---|---|
| `Image` | 55,439,372 B | `c0adedba7de461ae95218fe1bb501d069275e9c53ffa5cce33c3a1a3d31c6a0c` |
| `dtb` | 1,580,275 B | `db077314559f25032c4ef178a30089067155fd4ded5417aed4dc75d09fd25a82` |
| Flashable zip | 20,918,653 B | `e1651ce1c664908a5a834103e0183bfc288ebf904499150e4da834e1771ec9aa` |

### DTB determinism

The device tree blob was rebuilt from source and is **byte-identical** to the blob inside the
original 4.19.113 boot image, which proves the source tree identity:

| Entry | Size | SHA-256 prefix | Built from |
|---|---|---|---|
| 0 | 528,520 B | `b3aeb34a66528acc` | `kona-v2.1.dtb` |
| 1 | 528,516 B | `d68acf630e4473bc` | `kona-v2.dtb` |
| 2 | 523,066 B | `b463d63283610c57` | `kona.dtb` |
| 3 | 173 B | `9becad76b4e58a82` | RTIC `MP_DATA` (Samsung, runtime) |

---

## Kernel configuration highlights

All options below are built-in (`=y`). No external modules are required — and none can be
loaded, because `CONFIG_MODULE_SIG_FORCE=y`.

### Wi-Fi / monitor mode

```
CONFIG_MAC80211=y
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_CFG80211=y
CONFIG_CFG80211_WEXT=y
CONFIG_NL80211_TESTMODE=y
CONFIG_RFKILL=y
```

### USB Wi-Fi drivers (built-in)

| Driver | Supported adapters |
|---|---|
| `CONFIG_ATH9K_HTC=y` | AR9271, AR7010 |
| `CONFIG_CARL9170=y` | AR9170 |
| `CONFIG_RT2800USB=y` | RT3070, RT5370, RT5572, RT33xx, RT35xx, RT3573, RT53xx, RT55xx |
| `CONFIG_MT7601U=y` | MT7601U |
| `CONFIG_RTL8XXXU=y` | RTL8188, RTL8192, RTL8723 (CU/AU) |
| `CONFIG_RTL8187=y` | RTL8187L/B |
| `CONFIG_ZD1211RW=y` | ZD1211, ZD1211B, ZD1215 |
| `CONFIG_P54_USB=y` | Prism54 USB |

### KernelSU Next

```
CONFIG_KSU=y
CONFIG_KPROBES=y          # hook mode: Kprobes
```

* KernelSU Next **v3.4.0-legacy** (tag `33327`)
* Manager signature hash: `79e590113c4c4c0c222978e413a5faa801666957b1212a328e46c00c69821bf7`
* Core patches applied to `fs/open.c`, `fs/exec.c`, `fs/stat.c`, `fs/read_write.c`,
  `fs/namespace.c`, `kernel/reboot.c`, `drivers/input/input.c`, plus SELinux hooks

### Storage / memory

```
CONFIG_IOSCHED_BFQ=y
CONFIG_BFQ_GROUP_IOSCHED=y
CONFIG_BLK_WBT=y
CONFIG_BLK_WBT_MQ=y
CONFIG_BLK_WBT_SQ=y
CONFIG_BLK_CGROUP_IOLATENCY=y
```

`CONFIG_LRU_GEN` (MGLRU) is **not available** in this tree — see limitations below.

### USB / netfilter (NetHunter)

```
CONFIG_USB_GADGET=y
CONFIG_USB_CONFIGFS_F_HID=y     # BadUSB
CONFIG_HIDRAW=y
CONFIG_USB_HIDDEV=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_L2TP=y
CONFIG_TUN=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_CLS_U32=y
CONFIG_USB_USBNET=y
CONFIG_USB_RNDIS=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDC_NCM=y
```

Full resolved configuration: [`kernel/c2q_kor_singlew_defconfig`](kernel/c2q_kor_singlew_defconfig)

---

## Ramdisk

The flashable zip **ships no ramdisk**. The AnyKernel3 installer reuses the ramdisk already
installed on the device (Magisk first-stage init + `overlay.d`). This was verified safe: the
ramdisk inside the original 4.19.113 boot image and the one inside the 4.19.325 boot image
decompress to the **same 11,069,928-byte cpio with the same 28 entries**.

Magisk handles first-stage init; KernelSU Next runs from the kernel driver via Kprobes.
Both root solutions stay active at the same time.

---

## Flash instructions

1. Boot into **TWRP / OrangeFox**
2. Install `AjralDEV-Kernel-c2q-4.19.113-KSU-NetHunter-android13.zip`
3. Do **not** wipe anything
4. Reboot to system

The installer backs up the current boot partition to
`/sdcard/backup/boot-<YYYYMMDD-HHMMSS>.img` before writing.

### Verify after boot

```bash
su -c "uname -r"                                    # 4.19.113
su -c "magisk -v"                                   # 31.1:MAGISK:R
su -c "dmesg | grep -i kernelsu"                    # v3.4.0-legacy, hook: kprobes
su -c "zcat /proc/config.gz | grep MAC80211=y"
su -c "iw list | head -20"
```

### Enable monitor mode

```bash
su -c "ip link set wlan1 down"
su -c "iw dev wlan1 set type monitor"
su -c "ip link set wlan1 up"
su -c "iw dev wlan1 info"
```

A helper script is provided: [`scripts/monitor-mode.sh`](scripts/monitor-mode.sh)

---

## Known limitations

* **No MGLRU** — `CONFIG_LRU_GEN` does not exist in this 4.19.113 tree. The 4.19.325 build
  shipped a local MGLRU backport; this kernel uses classic LRU.
* **No out-of-tree module loading** — `CONFIG_MODULE_SIG_FORCE=y` and `CONFIG_MODVERSIONS=y`
  mean any external module must be signed with this kernel's private signing key. Drivers are
  built-in instead.
* **RTL8812AU / RTW88 not included** — these drivers are not part of the upstream 4.19 tree and
  were not backported.
* **TC/IFB** is not enabled in the Samsung base config, so NetHunter MitM setups that rely on
  `ifb` may not work. Plain `iptables` NAT still works.
* **On-board BCM4375** (`bcmdhd`) does not support monitor mode — only the USB adapters above.

---

## Build notes

Source tree: [`postkevone/c2q-kernelsu-next`](https://github.com/postkevone/c2q-kernelsu-next)
(base `N986NKSSAHYH1`, Linux 4.19.113), KernelSU Next `legacy` branch, AOSP clang 10.0.6.

Three host-environment issues had to be fixed to build this tree in 2026:

| Problem | Cause | Fix |
|---|---|---|
| `prerequisites cannot be defined in recipes` | GNU Make 4.4 vs Samsung `techpack` Makefiles | build with **GNU Make 4.3** |
| `undefined reference to ENGINE_*` | OpenSSL 4.x removed the ENGINE API used by `scripts/sign-file.c` | `#define OPENSSL_ENGINE_STUBS 1` in `scripts/sign-file.c` and `scripts/extract-cert.c` |
| `implicit declaration of strscpy_pad` | KernelSU Next guard assumes `strscpy_pad` exists since 4.14.222; it only landed in 4.20 | change the guard in `drivers/kernelsu/compat/kernel_compat.h` from `4.14.222` to `4.20.0` |

Applied changes are in [`patches/`](patches). Build script: [`scripts/build.sh`](scripts/build.sh)

---

## Rollback

Three independent rollback paths:

1. `/sdcard/backup/boot-<date>.img` — created automatically by the installer
2. The previous `4.19.325-AjralDEV` boot image
   (SHA-256 `15646f4fd9c813f7dc7dfc4f95450287dd503a0c1494e5a9deb77e522c6a4a1f`)
3. Re-flash the previous AnyKernel zip for 4.19.325

---

## License

The Linux kernel is licensed under **GPL-2.0**. See [`LICENSE`](LICENSE).
KernelSU Next is GPL-2.0. Any redistribution of the kernel binary must comply with the GPL;
the corresponding source tree, defconfig, and patches used for this build are published in
this repository.

Samsung-specific components remain the property of their respective owners. This is an
unofficial community build, not affiliated with or endorsed by Samsung.
