#!/bin/bash
zenity --question --text="WARNING: This is an experimental feature /n it may cause features to no longer function correctly /n Click Yes if you would like to update and No to cancel"
rc=$?
if [ "${rc}" == "1" ]; then
exit 1
fi
apt update
apt upgrade
pip install --upgrade pip
pip install mitmproxy
npm install -g apk-mitm
echo Update Finished
