<p align="center">
  <img src="assets/banner.svg" alt="AjralDEV Kernel — c2q" width="100%">
</p>

<p align="center">
  <a href="https://github.com/JackRipper-ID/AjralDEV-Kernel-c2q/releases/latest"><img alt="Release" src="https://img.shields.io/github/v/release/JackRipper-ID/AjralDEV-Kernel-c2q?style=for-the-badge&label=release&color=6366f1"></a>
  <img alt="Kernel" src="https://img.shields.io/badge/kernel-4.19.113-0ea5e9?style=for-the-badge">
  <img alt="KernelSU Next" src="https://img.shields.io/badge/KernelSU_Next-v3.4.0--legacy-22c55e?style=for-the-badge">
  <img alt="BORE" src="https://img.shields.io/badge/scheduler-BORE_5.1.0r2-f97316?style=for-the-badge">
  <img alt="NetHunter" src="https://img.shields.io/badge/NetHunter-monitor_%2B_injection-c084fc?style=for-the-badge">
  <img alt="License" src="https://img.shields.io/badge/license-GPL--2.0-f59e0b?style=for-the-badge">
</p>

<p align="center">
  <b>Built from Samsung's own source, not from another kernel tree.</b><br>
  <sub>KernelSU Next root &nbsp;·&nbsp; BORE scheduler &nbsp;·&nbsp; BFQ / BBR &nbsp;·&nbsp; MAC80211 monitor mode</sub>
</p>

---

## ⚡ What this is

A clean rebuild of the official Samsung open-source drop for the Galaxy Note20 Ultra 5G Snapdragon (`c2q` / SM-N986N, Android 13 · One UI 5.1.1).

Starting point: the `SM-N986N` source package (4.19.113), **70,909 files**. On top of it, exactly **26 entries changed** — 25 patched files plus the KernelSU Next driver directory. Nothing was imported from a community kernel tree, and no prebuilt binary was reused.

| | KernelSU Next | Monitor mode | BFQ default | BORE | MGLRU |
|:--|:--:|:--:|:--:|:--:|:--:|
| Stock Samsung 4.19.113 | ❌ | ❌ | ❌ | ❌ | ❌ |
| Community `4.19.325` build | ✅ | ❌ | ⚠️ compiled, CFQ default | ❌ | ✅ |
| **This build** | ✅ | ✅ | ✅ | ✅ | ❌ |

> [!NOTE]
> MGLRU (`CONFIG_LRU_GEN`) does not exist in the 4.19.113 Samsung tree. The backport is written against Android common / OnePlus 4.19 and cannot be merged into Samsung's `mm/vmscan.c` without rewriting large blocks, so this build uses the classic LRU.

---

## 🧩 What's inside

<table>
<tr>
<td width="50%" valign="top">

**Root — KernelSU Next only**
```ini
CONFIG_KSU=y
CONFIG_KSU_MANUAL_HOOK=y
CONFIG_KSU_ALLOWLIST_WORKAROUND=y
```
No Magisk, no hybrid ramdisk. Manual hooks are wired into `fs/open.c`, `fs/exec.c`, `fs/stat.c`, `fs/read_write.c`, `kernel/reboot.c`, `drivers/input/input.c`.
Root requires Samsung's UH / RKP / KDP off — see [Knox and Samsung security](#-knox-and-samsung-security).

</td>
<td width="50%" valign="top">

**Scheduler**
```ini
CONFIG_SCHED_BORE=y
CONFIG_SCHED_WALT=y
CONFIG_SCHED_TUNE=y
CONFIG_ENERGY_MODEL=y
CONFIG_CPU_BOOST=y
```
BORE `5.1.0r2` (burst-oriented response enhancer) on top of WALT + schedtune, so OneUI's app boosting still works.

</td>
</tr>
<tr>
<td width="50%" valign="top">

**Storage & network**
```ini
CONFIG_IOSCHED_BFQ=y
CONFIG_DEFAULT_BFQ=y
CONFIG_BLK_WBT=y
CONFIG_TCP_CONG_BBR=y
CONFIG_DEFAULT_BBR=y
```
BFQ is the default I/O scheduler, BBR the default TCP congestion control.

</td>
<td width="50%" valign="top">

**Memory**
```ini
CONFIG_ZRAM=y
CONFIG_ZSWAP=y
CONFIG_KSM=y
```
`zswap` with zstd, KSM enabled, plus f2fs compression (LZO / LZ4).

</td>
</tr>
<tr>
<td width="50%" valign="top">

**Radio**
```ini
CONFIG_MAC80211=y
CONFIG_MAC80211_MESH=y
CONFIG_CFG80211_WEXT=y
CONFIG_NL80211_TESTMODE=y
```
Monitor mode and frame injection on external adapters.

</td>
<td width="50%" valign="top">

**NetHunter plumbing**
```ini
CONFIG_USB_CONFIGFS_F_HID=y   # BadUSB
CONFIG_HIDRAW=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_BRIDGE_NF_EBTABLES=y
```

</td>
</tr>
</table>

### 📡 Supported USB adapters

| Driver | Chipsets |
|:--|:--|
| `ath9k_htc` | **AR9271**, AR7010 |
| `carl9170` | AR9170 |
| `rt2800usb` | RT3070, **RT5370**, RT5572, RT33xx, RT35xx |
| `mt7601u` | MT7601U |
| `rtl8xxxu` | RTL8188, RTL8192, RTL8723 |
| `rtl8187` | RTL8187L/B |
| `zd1211rw` | ZD1211, ZD1211B, ZD1215 |
| `p54usb` | Prism54 USB |

All built in (`=y`). No modules, no signing, no compile step on device.

---

## 📦 Downloads

| Asset | Size | SHA-256 |
|:--|--:|:--|
| [`AjralDEV-Kernel-c2q-4.19.113-AjralDEV-BORE-KSUNext-NetHunter.zip`](https://github.com/JackRipper-ID/AjralDEV-Kernel-c2q/releases/latest) | 21,508,992 B | `e498fd35bd3c10caa3a4ca6e83a7b199e19bf923a920d18d8550a9c5bbd4ca2d` |
| [`Image`](https://github.com/JackRipper-ID/AjralDEV-Kernel-c2q/releases/latest) | 55,459,852 B | `89b3a1dbc6ebfd40b2e6952fb6be5033d6f915b4ae672e9f3d257f7db7b1ec01` |
| [`dtb`](https://github.com/JackRipper-ID/AjralDEV-Kernel-c2q/releases/latest) | 1,580,275 B | `db077314559f25032c4ef178a30089067155fd4ded5417aed4dc75d09fd25a82` |

---

## 🚀 Flash

```text
1. Boot into TWRP / OrangeFox
2. Install the zip
3. Do not wipe anything
4. Reboot, then install KernelSUNext.apk to manage root
```

The installer copies the current boot partition to `/sdcard/backup/boot-<YYYYMMDD-HHMMSS>.img` **before** writing anything.

<details>
<summary><b>Verify after boot</b></summary>

```bash
su -c "uname -r"                                  # 4.19.113-AjralDEV-Kernel
ksu --version                                     # v3.4.0-legacy
su -c "zcat /proc/config.gz | grep SCHED_BORE=y"
su -c "cat /sys/block/sda/queue/scheduler"        # [bfq]
su -c "sysctl net.ipv4.tcp_congestion_control"    # bbr
su -c "iw list | head -20"
```

</details>

<details>
<summary><b>Enable monitor mode</b></summary>

```bash
su -c "ip link set wlan1 down"
su -c "iw dev wlan1 set type monitor"
su -c "ip link set wlan1 up"
su -c "iw dev wlan1 info"
```

</details>

---

## 🔬 Build integrity

| Metric | Value |
|:--|--:|
| Files in the source tree | 70,909 |
| Entries changed | 26 (25 files + `drivers/kernelsu/`) |
| Patched, non-additive lines | `kernel/sched/fair.c` only (−13) |
| MGLRU / `mm/` changes | none |

The DTB is byte-identical to the blob inside the original 4.19.113 boot image, confirming the source tree identity.

| DTB entry | Size | SHA-256 prefix | Origin |
|:--|--:|:--|:--|
| 0 | 528,520 B | `b3aeb34a66528acc` | `kona-v2.1.dtb` |
| 1 | 528,516 B | `d68acf630e4473bc` | `kona-v2.dtb` |
| 2 | 523,066 B | `b463d63283610c57` | `kona.dtb` |
| 3 | 173 B | `9becad76b4e58a82` | RTIC `MP_DATA` |

```text
Linux version 4.19.113-AjralDEV-Kernel (ajraldev@Killer)
clang version 10.0.6 for Android NDK
#2 SMP PREEMPT Sun Nov 22 07:41:01 WIB 2026
```

---

## ⚠️ Known limitations

| Limitation | Detail |
|:--|:--|
| **No MGLRU** | `CONFIG_LRU_GEN` is absent from the 4.19.113 tree; the 5.4-style backport does not fit Samsung's `vmscan.c` |
| **No UCLAMP** | `SCHED_TUNE` depends on `!UCLAMP_TASK`, and Samsung's `fair.c` calls `schedtune_task_margin()` unguarded — schedtune stays, UCLAMP cannot be enabled |
| **UH / RKP / KDP off** | KernelSU Next aborts the build while Samsung's micro-hypervisor, Real-time Kernel Protection or Kernel Data Protection are on, since they protect exactly what root must modify. All three stay disabled (their upstream default) |
| **CFP (JOPP/ROPP) off** | The vendor defconfig enables it, but its final vmlinux pass is a Python 2 script (`scripts/cfp/instrument.py`) and this environment has no Python 2. Same choice as the previous boot-proven build: CFP off |
| **No external modules** | `MODULE_SIG_FORCE=y`; every driver is built in |
| **No on-board monitor** | BCM4375 (`bcmdhd`) is STA-only; monitor mode needs a USB adapter |
| **Android 16 / 17 untested** | No official AOSP or One UI build exists for `c2q`; support is config-level only |

---

## 🔐 Knox and Samsung security

Root has one non-negotiable cost. Samsung's kernel-side integrity enforcement pins kernel text, `cred` and namespace structures against modification — exactly what KernelSU Next must do — so three options are disabled:

```ini
# CONFIG_UH is not set         # micro-hypervisor
# CONFIG_UH_RKP is not set     # Realtime Kernel Protection
# CONFIG_KDP_CRED is not set   # Kernel Data Protection (+ KDP_NS / KDP_DMAP)
```

The driver refuses to build while any of them is on. Everything else in the security stack is left as stock: `CONFIG_FIVE=y`, `CONFIG_DM_VERITY=y` + `CONFIG_DM_VERITY_FEC=y`, `CONFIG_SECURITY_DEFEX=y` (stock rules untouched), `CONFIG_SDP=y`, `CONFIG_KNOX_NCM=y`, SELinux enforcing.

One more option is off for a build-environment reason rather than a root reason:

```ini
# CONFIG_CFP is not set   # Control Flow Protection (JOPP/ROPP)
```

The vendor defconfig enables it, but its final `vmlinux` pass is a Python 2 script (`scripts/cfp/instrument.py`, called from `scripts/link-vmlinux.sh`), and this build environment has no Python 2. CFP is kernel self-protection against ROP/JOP gadgets — turning it off costs that hardening and the JOPP/ROPP trampoline overhead. It has no bearing on Knox, FIVE, dm-verity or SELinux, and it is the same setting the previous boot-proven build used.

<table>
<tr><td><b>Still works</b></td><td>FIVE file integrity, dm-verity/FEC, DEFEX policy, SDP, SELinux, app sandbox, Play Integrity basic checks on non-rooted-looking apps</td></tr>
<tr><td><b>Broken (not by this kernel)</b></td><td>Samsung Pass / Wallet (Pay), Secure Folder, Secure Wi-Fi, Knox-attested banking apps — all need an <b>untripped Knox warranty bit</b></td></tr>
</table>

> [!IMPORTANT]
> Unlocking the bootloader trips the Knox warranty bit permanently, so those services were already unavailable before this kernel was flashed, and no custom kernel can bring them back while root exists. The "phone is not running Samsung's official software" screen at boot comes from the bootloader, not from this build, and cannot be removed by a kernel.

What still helps: the KernelSU Next manager's denylist ("Umount modules"), its SELinux hiding and `sulog` (kernel-side root logging — disable it in the manager). Those defeat apps that only look for `su` binaries, mounts or SELinux state; they cannot beat Knox attestation or hardware-backed Play Integrity, and no kernel can.



## 🛠 Reproducing the build

Base: official Samsung `SM-N986N` open-source package, Linux 4.19.113 · AOSP clang 10.0.6 · GNU Make 4.3

| Component | Source |
|:--|:--|
| Scheduler | [firelzrd/bore-scheduler](https://github.com/firelzrd/bore-scheduler) `5.1.0r2`, 4.19.y branch (3-way merged) |
| Root | [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) `v3.4.0-legacy` (`8af3d4f`), manual hook mode, version pinned to `33327` |
| Config | 8 fragments merged over `c2q_kor_singlew_defconfig`, then `olddefconfig` |

Host-environment and vendor-tree fixes required to build this at all:

| Symptom | Cause | Fix |
|:--|:--|:--|
| `prerequisites cannot be defined in recipes` | GNU Make 4.4 vs Samsung `techpack` | build with **GNU Make 4.3** |
| `undefined reference to ENGINE_*` | OpenSSL 4.x removed the ENGINE API | `#define OPENSSL_ENGINE_STUBS 1` in `scripts/sign-file.c` + `scripts/extract-cert.c` |
| `forbidden warning: fair.c` | BORE uses C99 declarations, `gcc-wrapper.py` fails on any warning | `-Wno-declaration-after-statement` in `KBUILD_CFLAGS` |
| `schedtune_task_margin` not declared | `SCHED_TUNE` depends on `!UCLAMP_TASK`; enabling UCLAMP silently drops schedtune, which Samsung's `fair.c` calls unguarded | keep `SCHED_TUNE`, leave `UCLAMP_TASK` off |
| `update_burst_penalty` unused | `CONFIG_FAST_TRACK=y` compiles away BORE's accounting block | call the burst accounting from the FAST_TRACK path |
| `uapi/app_profile.h` not found | the driver's `include/uapi` symlink points outside the tree | populate `include/uapi` with the 6 shared headers |
| `CONFIG_UH, CONFIG_KDP and CONFIG_RKP is enabled!` | KernelSU Next aborts on Samsung integrity features | disable UH / UH_RKP / KDP (`70-samsung-compat` fragment) |
| `implicit declaration of strscpy_pad` | `strscpy_pad` arrived in 4.20 and is absent from Samsung 4.19 | Kbuild probe + fallback in `kernel_compat.h` |
| `redefinition of 'three'` | the BORE patch declares helpers Samsung's `sysctl.c` already defines | reuse Samsung's `three`, declare only `sixty_four` / `maxval_12_bits` |
| `CFP : instrumenting vmlinux... SyntaxError: Missing parentheses in call to 'print'` | `scripts/cfp/instrument.py` is Python 2 and this environment has no Python 2 | `# CONFIG_CFP is not set` (also the previous boot-proven setting) |

---

## ↩️ Rollback

1. `/sdcard/backup/boot-<date>.img` — written automatically by the installer
2. Re-flash the previous AnyKernel zip

---

## 📄 License

Kernel sources are **GPL-2.0**. See [LICENSE](LICENSE). Any redistribution of the binary must comply with the GPL — the defconfig, patches, and build scripts used here are published in this repository.

KernelSU Next is GPL-2.0. Samsung components remain the property of their respective owners. This is an unofficial community build, not affiliated with or endorsed by Samsung.

<p align="center">
  <sub>Built by <a href="https://github.com/JackRipper-ID">JackRipper-ID</a> · AjralDEV</sub>
</p>
