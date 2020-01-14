#!/bin/bash
lxsudo mitmweb --anticomp --anticache --listen-host 0.0.0.0 --mode transparent --no-http2 --showhost --save-stream-file ~/mitmproxy-`date +%s`-flow.cap --ssl-insecure
exit 0
