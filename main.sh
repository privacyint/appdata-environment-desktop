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
  zenity --question --width=600 --height=400 --text="WARNING: This is an experimental feature \n it may cause features to no longer function correctly \n Click Yes if you would like to update and No to cancel"
  rc=$?
  if [ "${rc}" == "1" ]; then
  exit 1
  fi
  qterminal --execute "sudo /home/privacy/Desktop/systemcfg-scripts/update.sh"
fi

if [ "$ask" == "Exit" ]; then
    break
fi

done
exit 0
