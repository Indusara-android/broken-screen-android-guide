#!/system/bin/sh
resetprop ro.adb.secure 0
resetprop persist.sys.usb.config adb
resetprop persist.service.adb.enable 1
resetprop ro.debuggable 1
resetprop ro.secure 0
