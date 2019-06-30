
#!/bin/bash
echo "This is undocumented functionality of this toolkit"
lxsudo mitmweb --anticomp --anticache --listen-host 0.0.0.0 --no-http2 --showhost --save-stream-file ~/mitmproxy-`date +%s`-ios-flow.cap --ssl-insecure
exit 0
