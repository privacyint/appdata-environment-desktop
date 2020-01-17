#!/bin/bash
while :
do
ask=`zenity --list --title="Please Select a task" --column="0" "Configure Wireless Adapter" "Enable hostapd" "Run an APK through APK-Mitm" "Start mitmproxy" "Show the documentation" "Exit" --width=200 --height=300 --hide-header`
if [ "$ask" == "Configure Wireless Adapter" ]; then
    bash ./systemcfg-scripts/change_wireless_interface.sh
fi

if [ "$ask" == "Enable hostapd" ]; then
    bash ./systemcfg-scripts/administer_service.sh
fi

if [ "$ask" == "Run an APK through APK-Mitm" ]; then
    bash ./apkman-scripts/zenity-apkmitm.sh
fi

if [ "$ask" == "Start mitmproxy" ]; then
    ./mitmproxy-scripts/mitmproxy_start.sh
fi

if [ "$ask" == "Show the documentation" ]; then
    grip -b ~/Desktop &
fi

if [ "$ask" == "Exit" ]; then
    break
fi

done
exit 0
