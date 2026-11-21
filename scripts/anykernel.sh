# AnyKernel3 Ramdisk Mod Script
# AjralDEV Kernel c2q — buatan AjralDEV
# Build: 4.19.113 + KernelSU Next v3.4.0-legacy + NetHunter (MAC80211 + USB WiFi monitor)

## AnyKernel setup
# begin properties
properties() { '
kernel.string=AjralDEV Kernel c2q 4.19.113 KSU-Next + NetHunter — buatan AjralDEV
do.devicecheck=0
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=c2q
device.name2=y2q
device.name3=x1q
device.name4=c1q
supported.versions=13 - 16
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/platform/soc/1d84000.ufshc/by-name/boot;
[ -e "$block" ] || block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

ui_print " ";
ui_print "  ----------------------------------------------";
ui_print "   AjralDEV Kernel c2q  —  4.19.113";
ui_print "   KernelSU Next v3.4.0-legacy (Kprobes)";
ui_print "   NetHunter: MAC80211 + 9 driver USB WiFi";
ui_print "   BFQ + WBT + KPROBES + KALLSYMS_ALL";
ui_print "   buatan AjralDEV";
ui_print "  ----------------------------------------------";
ui_print " ";

## Backup boot partition sebelum menyentuh apa pun
boot_backup=/sdcard/backup/boot-$(date +%Y%m%d-%H%M%S).img;
mkdir -p /sdcard/backup 2>/dev/null;
if [ -e "$block" ]; then
  dd if="$block" of="$boot_backup" bs=4096 2>/dev/null && \
    ui_print "  Backup boot: $boot_backup" || \
    ui_print "  (backup boot gagal, lanjut)";
fi;

## AnyKernel boot install
dump_boot;

# KernelSU Next: butuh sepolicy patch di ramdisk (hybrid dengan Magisk)
# biarkan Magisk tetap jadi first-stage, KSU aktif via driver kernel
write_boot;

ui_print " ";
ui_print "  Selesai. Reboot ke system.";
ui_print "  Root: Magisk + KernelSU Next dua-duanya aktif.";
ui_print "  WiFi monitor: iw list | grep -A12 'Supported interface modes'";
ui_print " ";
