# broken-screen-android-guide
How to enable USB debugging and screen mirroring on a broken-screen Android device using TWRP + Magisk

## 🎯 What This Guide Covers

This guide shows you how to **enable USB Debugging** and **mirror your screen to a PC** on an Android device with a **completely dead display**, when USB Debugging was **never enabled**.

**Tested on:** Samsung Galaxy S5 (SM-G900F) running crDroid 7 (Android 11)

---

## ❓ The Problem

- Display is completely dead
- USB Debugging was never enabled
- You have TWRP recovery installed
- You have Magisk installed
- Most guides say "you're stuck"

**But you're not.** This guide shows you how I did it.

---

## 🛠️ Requirements

- A PC running Linux (tested on Linux Mint 22.3)
- USB cable (data-capable, not charge-only)
- TWRP recovery already installed
- Magisk already installed
- Patience

---

## 📖 Step-by-Step Guide

### Step 1: Boot into TWRP

1. Power off the phone completely
2. Hold **Volume Up + Home + Power** simultaneously
3. Wait 10-15 seconds
4. Connect to PC via USB
5. Verify: `adb devices` → should show `recovery`

### Step 2: Backup Your Data (DO THIS FIRST!)

```bash
mkdir -p ~/s5-backup
adb pull /sdcard/ ~/s5-backup/
```

### Step 3: Mount System Partition

```bash
adb shell ls -la /dev/block/bootdevice/by-name/
adb shell mount -o rw /dev/block/bootdevice/by-name/system /system
adb shell mount | grep system
```

### Step 4: Create a Magisk Module

**Why?** On Android 11+, `/system` becomes read-only on boot. Magisk modules apply changes systemlessly.

Create the module files on your PC:

```bash
mkdir -p ~/usb-debug-module/META-INF/com/google/android
cd ~/usb-debug-module
```

**module.prop:**
```
id=usbdebug
name=USB Debug Enabler
version=1.0
versionCode=1
author=YourName
description=Enables USB debugging on boot for broken screen devices
```

**post-fs-data.sh:**
```bash
#!/system/bin/sh
resetprop ro.adb.secure 0
resetprop persist.sys.usb.config adb
resetprop persist.service.adb.enable 1
resetprop ro.debuggable 1
resetprop ro.secure 0
```

**system.prop:**
```
ro.adb.secure=0
persist.sys.usb.config=adb
persist.service.adb.enable=1
ro.debuggable=1
ro.secure=0
```

**META-INF/com/google/android/update-binary:**
```bash
#!/sbin/sh
umask 022
OUTFD=$2
ZIPFILE=$3
mount /data 2>/dev/null
mkdir -p /data/adb/modules/usbdebug
cp -af $ZIPFILE /data/adb/modules/usbdebug/
echo "USB Debug module installed"
```

**META-INF/com/google/android/updater-script:**
```
#MAGISK
```

**Zip and install:**
```bash
zip -r9 ~/usb-debug-module.zip *
adb push ~/usb-debug-module.zip /sdcard/
adb shell twrp install /sdcard/usb-debug-module.zip
```

### Step 5: Manually Verify Module Files

```bash
adb shell ls -la /data/adb/modules/usbdebug/
adb push ~/usb-debug-module/module.prop /data/adb/modules/usbdebug/module.prop
adb push ~/usb-debug-module/post-fs-data.sh /data/adb/modules/usbdebug/post-fs-data.sh
adb push ~/usb-debug-module/system.prop /data/adb/modules/usbdebug/system.prop
adb shell chmod 755 /data/adb/modules/usbdebug/post-fs-data.sh
```

### Step 6: Push ADB Key

```bash
adb shell mkdir -p /data/misc/adb/
adb push ~/.android/adbkey.pub /data/misc/adb/adb_keys
adb shell chmod 640 /data/misc/adb/adb_keys
adb shell chown system:shell /data/misc/adb/adb_keys
```

### Step 7: Reboot and Test

```bash
adb reboot
# Wait 60-90 seconds
adb devices
```

**Expected:** `XXXXXXXX    device`

### Step 8: Screen Mirroring with Scrcpy

```bash
sudo apt install scrcpy
scrcpy
```

---

## 🧠 Why This Works

- TWRP's ADB works without USB Debugging in Android
- Magisk modules apply changes systemlessly
- `resetprop` sets properties before Android checks them
- ADB key push bypasses the authorization prompt

---

## ⚠️ Warnings

- `ro.secure=0` and `ro.debuggable=1` reduce security
- Always backup your data first
- Tested on SM-G900F + crDroid 7

---

## 🙏 Credits

Written by **Indusara** (Sri Lanka)
With help from **DeepSeek AI**

---

## 📜 License

MIT License

---
