#!/bin/bash
echo "This Script Bootstraps APK's to work with non-rooted devices"
zenity --info --no-wrap --text="This program is an assistant for making APKs compatible with mitmproxy\nPlease select a APK File to process"
APKFILE=$(zenity --file-selection --file-filter="*.apk")
mkdir ~/apk-mitm-processed
cd ~/apk-mitm-processed
lxsudo apk-mitm $APKFILE
## zenity --progress --text="Processing APK File:\n$APKFILE" --pulsate --no-cancel --auto-kill
pcmanfm-qt -n $(dirname $APKFILE) &
echo Complete
exit 0
