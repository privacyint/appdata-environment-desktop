#!/bin/bash
lxsudo mitmweb --anticomp --anticache --listen-host 0.0.0.0 --mode transparent --showhost --save-stream-file ~/mitmproxy-`date +%s`-flow.cap --ssl-insecure &
zenity --progress --text="mitmproxy is Running\nClose this dialog to exit mitmproxy" --pulsate
lxsudo pkill mitmweb
