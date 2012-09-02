#!/sbin/sh

echo 04E8 > /sys/class/android_usb/android0/idVendor
echo 68C1 > /sys/class/android_usb/android0/idProduct
echo "mass_storage,adb" > /sys/class/android_usb/android0/functions
