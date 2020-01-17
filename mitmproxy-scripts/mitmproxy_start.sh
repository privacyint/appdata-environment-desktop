#!/bin/bash
lxsudo mitmweb --anticomp --anticache --listen-host 0.0.0.0 --mode transparent --showhost --save-stream-file ~/mitmproxy-`date +%s`-flow.cap --ssl-insecure &
zenity --progress --text="MITMPRoxy is Running, close this dialog to exit" --pulsate --no-cancel
lxsudo pkill mitmweb
exit 0
