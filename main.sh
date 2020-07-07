#!/bin/bash
while :
do
ask=`zenity --list --title="Please Select a task" --column="0" "Configure Wireless Adapter" "Enable hostapd" "Run an APK through APK-Mitm" "Start mitmproxy" "Show the documentation" "Update -- Experimental" "Exit" --width=450 --height=400 --hide-header`
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

if [ "$ask" == "Update -- Experimental" ]; then
  qterminal --workingfir ~ --execute "lxsudo apt update; lxsudo apt upgrade; lxsudo pip install --upgrade pip; lxsudo pip install mitmproxy; lxsudo npm install -g apk-mitm"
fi

if [ "$ask" == "Exit" ]; then
    break
fi

done
exit 0
