#!/bin/bash
## Determine the NIC
wlannic=`sudo iw dev | awk '$1=="Interface"{print $2}'`
## Ask the user to apply to config
zenity --info --text="If you experience issues, try running this script as root"
if [ "$wlannic" == "" ]; then
zenity --warning --text="Your Wireless NIC was not detected"
exit 1
fi
zenity --question --width=600 --height=400 --text="Your Wireless NIC appears to be $wlannic, do you want to automatically update configuration files?"
rc=$?
if [ "${rc}" == "1" ]; then
break
fi
sudo cat << EOF1 > /etc/hostapd/hostapd.conf
interface=$wlannic
driver=nl80211
ssid=pi_maninthemiddle
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=3
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=privacyint
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF1
sudo cat << EOF2 > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface (adapter 1 in VBOX)
allow-hotplug enp0s3
auto enp0s3
iface enp0s3 inet dhcp

##Wifi controller was automatically added below

auto $wlannic
iface $wlannic inet static
       address 100.64.32.1
       netmask 255.255.255.0
EOF2
sudo cat << EOF3 > /etc/iptables/rules.v4
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A PREROUTING -i $wlannic -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
-A PREROUTING -i $wlannic -p tcp -m tcp --dport 443 -j REDIRECT --to-ports 8080
-A POSTROUTING -o enp0s3 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i enp0s3 -o $wlannic -m state --state RELATED,ESTABLISHED -j ACCEPT
COMMIT
EOF3
echo "File Changes Complete"
