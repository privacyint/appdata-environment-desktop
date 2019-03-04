# Privacy International's data interception environment
`Version: 2.1.2-20190305`

- [Privacy International's data interception environment](#privacy-internationals-data-interception-environment)
  - [Quick Start Guide](#quick-start-guide)
    - [Prerequisites (as this is a quick start guide):](#prerequisites-as-this-is-a-quick-start-guide)
    - [Step 1 - Download](#step-1---download)
    - [Step 2 - Importation](#step-2---importation)
    - [Step 3 - Initialising](#step-3---initialising)
    - [Step 4 - Setup](#step-4---setup)
    - [Step 5 - Capture](#step-5---capture)
    - [Step 6 - Android Nougat or Later](#step-6---android-nougat-or-later)
  - [Background](#background)
  - [Theory](#theory)
  - [Implementation](#implementation)
    - [Virtualbox (6.0.4)](#virtualbox-604)
    - [Debian (10) (Buster / Unstable)](#debian-10-buster--unstable)
    - [mitmproxy (4.0.4)](#mitmproxy-404)
    - [dnsmasq (2.80) (`Enabled`)](#dnsmasq-280-enabled)
    - [hostapd (2.6) (`Disabled`)](#hostapd-26-disabled)
    - [iptables (1.8.2)](#iptables-182)
    - [Component Layout](#component-layout)
  - [Usage](#usage)
    - [Prerequisites](#prerequisites)
      - [Required Changes](#required-changes)
      - [Before starting the VM](#before-starting-the-vm)
      - [Once started](#once-started)
      - [Configuring your handset](#configuring-your-handset)
    - [Methodology](#methodology)
  - [Troubleshooting](#troubleshooting)

## Quick Start Guide

> For those who just want to get analysing

### Prerequisites (as this is a quick start guide):

- VirtualBox 6.x Installed
- A Wifi USB Dongle (specifically [https://amzn.com/B00JZFT3VS](https:://amzn.com/B00JZFT3VS) or any other Ralink 5370 Chipset USB Adapter) 
- Internet Connectivity
- Some experience of Unix like operating systems (particularly systemd)
- Some experience with Android and the Android Developer Bridge (ADB)
- An Android Handset that is rooted and has ADB enabled. Running Oreo or earlier

### Step 1 - Download

Head to Privacy International's website and download the VM: [https://privacyinternational.org/mitmproxy19]()

Download the Virtual Appliance (OVA, extension .ova)

### Step 2 - Importation

Double Click on the OVA. This should open VirtualBox if .ova is associated with VirtualBox. Otherwise you can click Import Appliance from the File Menu in VirtualBox

Click import

Read and accept the licence agreement

### Step 3 - Initialising

Plug in your Wifi USB if you haven't done so already.

Make sure the Wifi USB dongle is connected to the Virtual Machine ( Menu Bar - Device -> USB )

### Step 4 - Setup

Start the Virtual machine

Once the desktop has loaded, you will need to run 
change_wireless_interface.sh and provide it with the device identifier for your wireless network dongle

Open the Terminal (Applications -> System Tools -> QTerminal)

Type the following command ```sudo service systemctl enable hostapd``` this will enable the Wireless Daemon

**Reboot the Virtual Machine**

Check on your mobile device and see if it can connect to the WiFi network "```pi_maninthemiddle```".

**Troubleshooting:**
(most of these require the use of the terminal)

If you cannot see the "```pi_maninthemiddle```" network, something is likely wrong with either your hardware or hostapd. 

- Double check that you WiFi dongle is connected to the Virtual Machine.
- Make sure the interface name is correct in ```sudo nano /etc/hostapd/hostapd.conf```
- You can run hostapd manually, to see if there is any other issues with starting. e.g: ```sudo killall hostapd; sleep 4;sudo hostapd -p /etc/hostapd/hostapd.conf```

If you are not being assigned an IP address (Your device can see the network, but it keeps looping between connecting states)

- Restart dnsmasq ```sudo service dnsmasq restart```

Your device says "Connected, no Internet"

This is good! This means that your device is waiting for mitmproxy to be started

You can start mitmproxy using the "```mitmproxy_start.sh```" on the desktop

When you have finished with you can end your session "```mitmproxy_stop.sh```", your data will be saved in home

### Step 5 - Capture

Once you have started mitmproxy, visit ```http://mitm.it``` you should see prompts to install the certificate for your device. Install the certificate, and using an app like Chrome, see if you can browse the Internet

If you are getting errors in the logfile for mitmproxy stating that the certificate is not trusted, see below - Step 6

### Step 6 - Android Nougat or Later

Google changed the way the certificate store works in Android Nougat, please follow [this guide to correctly](https://blog.jeroenhd.nl/article/android-7-nougat-and-certificate-authorities) install your certificate.

As this is a quick start rough guide is:
Get the ID of the Certificate in a format that Android Expects

`sudo openssl x509 -inform PEM -subject_hash_old -in /root/.mitmproxy/mitmproxy-ca-cert.pem | head -1`

Note the output: e.g "abcdef12"

Copy the Certificate to the Device over ADB

`adb push /root/.mitmproxy/mitmproxy-ca-cert.pem /sdcard/<NamefromOpenSSLOutput>.0`

Remount the /system partition, copy the certificate, set its permissions (requires superuser access)

```
adb shell
su
mount -o remount,rw /system
cp /sdcard/<NamefromOpenSSLOutput>.0 /system/etc/security/cacerts
chmod 644 /system/etc/security/cacerts/NamefromOpenSSLOutput>.0
chown root:root /system/etc/security/cacerts/NamefromOpenSSLOutput>.0
mount -o remount,ro /system
```

Then we should reboot the device

```
reboot
```

Once restarted if you got to on the Android device (names may vary by version) Setting > Security > Encryption & Credentials > Trusted Credentials > System you should see mitmproxy's certificate listed.

## Background
In December 2018, [Privacy International](https://privacyinternational.org) released a [report](https://privacyinternational.org/report/2647/how-apps-android-share-data-facebook-report) highlighting how [Facebook can track you via Android apps even when your not a Facebook user](https://privacyinternational.org/appdata). [Frederike Kaltheuner](https://twitter.com/F_kaltheuner) and [Christopher Weatherhead](https://twitter.com/cjfweatherhead) presented the findings of this report at the [35th Chaos Computer Congress (35C3)](https://media.ccc.de/v/35c3-9941-how_facebook_tracks_you_on_android). Privacy International committed during that talk to releasing their environment used to conduct this research so as allow others to either repeat or expand on it.

Although the tools themselves are relatively trivial and there are already generic toolkits (such as Kali) that encompass them, this Virtual Machine is specifically for one purpose, and includes documentation to assist with that purpose, hopefully negating some of the necessity to read forum posts or disparate documentation.

This is a replica of the original environment used to conduct the research, there are a number of reasons why the original environment was unsuitable for redistribution, principally potential issues around licensing due to the use of proprietary drivers. Additionally the original environment was devised in June 2018 and many of tools and features had been subsequently update, the updated software is present in this environment.

## Theory

This toolkit is built around a flaw that exists in the trust paradigm used extensively on the Internet. When secure connections are established such as HTTPS, the client checks against an internal store of "trust anchors" in its "trust store" known as certificate authorities (or CAs for short). CA's exist in most operating systems through a number of methods, predominantly commercial agreements. This toolkit introduces are own CA that we add to the "trust store" which allows us to intercept secure traffic in transit, because the client now trusts this CA too in addition to the preconfigured ones.

This is where the term man-in-the-middle comes from, as we are sitting between the client and the server in the middle and intercepting and analysing the communication.

## Implementation

Inside this toolkit there are number of components which work together to allow for interception of data in transit. Let us talk through each element and how they work together, then I will discuss the various ways that they can be used

### Virtualbox (6.0.4)

Virtualbox is a free cross-platform Virtual Machine manager, it allows for one operating system to be run inside another by emulating the features of a physical computer virtually. As far as the operating system inside the Virtual Machine is concerned it is running on physical hardware (mostly). The advantage of doing this is that the hardware is abstract and software portable, so can be redistributed, it also means that the activity inside the virtual machine is contained and isolated from the real operating system that you use.

### Debian (10) (Buster / Unstable)

Debian is a flavour of linux, a unix-like kernel and operating system architecture. Debian Buster is currently the development build for the next major release of the operating system. Buster differs from the previous release (Stretch) in that it incorporates an updated version of Python which eases the installation of mitmproxy, a major component of this toolset

### mitmproxy (4.0.4)

mitmproxy is an open-source proxy (intermediary) server written in Python, it essentially takes connections in on one side, opens them up for analysis and then forwards them on to the other side in full-duplex. Its key feature is that it generates the required certificates in real time so that the incoming connection (from the client), believes that the proxy is the real destination. In the configured environment mitmproxy is configured in "transparent" mode, this means no additional settings need to be changed on the client other than the installation of mitmproxy's certificate.

### dnsmasq (2.80) (`Enabled`)

dnsmasq is a lightweight DNS (domain name service) and DHCP (dynamic-host configuration protocol) server, it serves two purposes, firstly it gives out IP addresses that allow devices to join a network without having them be configured manually this includes setting all the parameters such as DNS server, default route and domain. Secondarily it services DNS requests which involves predominantly turning domain names such as `privacyinternational.org` into IP addresses such as `144.76.205.68`

### hostapd (2.6) (`Disabled`)

hostapd is a configurable 802.11 (Wireless LAN) daemon, it allows wireless devices to be configured in a number of ways. In this toolset it is disabled by default as I don't know what WLAN controller you are using, it does however have a sane default configuration setup and can be easily enabled.

### iptables (1.8.2)

iptables is the de-facto standard firewalling system in many linux based operation systems, it uses a table of human-readable rules to categorise and manipulate traffic through a set of well known networking states. In this toolset it serves two purposes, it feeds traffic from ports 80 (http) and 443 (https) into mitmproxy, it also allows for other connections to be masqueraded so that the VM shall act like a router.

### Component Layout

```
+----------+          +-------------------------+             +--------------+
|  Public  +----------+  Privacy International  +-------------+Android Device|
| Internet |         ||  MitmProxy Environment  ||  Wireless: |with mitm cert|
+----------+         ||        VirtualBox       ||pi_mitmproxy+--------------+
               enp0s3+---------------------------+USB WiFi
                (NAT)                             Dongle

```

Lets walk through the diagram from left-to-right. The Internet as displayed in the diagram, would be which ever way you usually connect to the internet.  Adapter 1 in virtualbox (enp0s3 inside the VM) should be set as a NAT device, this will mean that the VM will use the hosts network connection to gain access to the internet.

The Virtualbox VM should be booted and mitmproxy should be running before trying to connect any downstream devices. There are scripts on the desktop which I will explain in more detail in the usage section.

To the right of the VM is a wireless NIC (I assume a USB dongle), in the shipped configuration this should be disabled, and should be configured before attempting to run mitmproxy. It will host the Wireless network `pi_mitmproxy`

Finally on the far right is the device you want to analyse, this is assumed to be an Android Phone. The following changes will need to be made to device
- The network will need to be changed to that provided by the WLAN NIC
- You will need to install mitmproxy's certificate into the devices trust store, further instructions for this can be found below


## Usage

### Prerequisites

* A Notebook or Desktop, with internet access, capable of running VirtualBox 6.x
* A Device you wish to analyse, in this guide an Android phone is assumed, and it is assumed to be rooted
* A wireless USB Dongle, the main guide will assume a Ralink based one, installation and configuration of the multitude of wireless network adapters falls outside the scope of this guide

My suggestion for USB Dongles would be:

[amzn.com/B019XUDHFC](amzn.com/B019XUDHFC) (they are not fancy, but they do work) (search amazon for ralink rt5370 in your own country)

#### Required Changes

As your environment and hardware will be different to mine, there are few things worth checking before starting the Virtual Machine.

#### Before starting the VM

**The number of assigned CPU's and quantity of Memory**

You may want to check that you can allocate the required resources for the VM, in its default state the VM is allocated 2CPU's and 1024MB's RAM. This means that the minimum requirements are 2CPUs and 2048MBs RAM on the host. This setup won't be particularly performant I would strongly recommend increasing both of these to 4CPUs and 2048MBs RAM if your host system has the capacity

**Network Controllers**

You should check that your Wireless NIC is correctly connected to the Virtual Machine, its best to do this before trying to boot the VM!

#### Once started

>**Login**

> Login should now be automatic, however if required, details below

>The default username and password is:

>Username: `privacy` <br />
Password: `international`

**Internet Connectivity**

 You can test this after the VM has booted by opening a browser and seeing if sites like `google.com` load correctly.

 **Desktop Items**

 There are a number of desktop items, most of them linking to configuration files. Below I list the filenames and their purposes
 
LICENSE.md
README.md
administer_service.sh
change_dhcp_settings.sh	
change_network_interfaces.sh
change_sources_list.sh
change_wificonfig.sh
mitmproxy_start.sh
mitmproxy_stop.sh
nic_change.sh
 
 
 **In the browser** (Firefox)

#### Configuring your handset

Google changed the way the certificate store works in Android Nougat, please follow [this guide to correctly](https://blog.jeroenhd.nl/article/android-7-nougat-and-certificate-authorities) to install mitmproxy's certificate. If you are using earlier versions of Android, you should be able to visit mitm.it once connected to your mitmproxy access point, and install the certificate directly. The abridged steps for installing on Nougat and later are below.

The abridged steps are as follows:
Get the ID of the Certificate in a format that Android Expects

`sudo openssl x509 -inform PEM -subject_hash_old -in /root/.mitmproxy/mitmproxy-ca-cert.pem | head -1`

Note the output: e.g "abcdef12"

Copy the Certificate to the Device over ADB

`adb push /root/.mitmproxy/mitmproxy-ca-cert.pem /sdcard/<NamefromOpenSSLOutput>.0`

Remount the /system partition, copy the certificate, set its permissions (requires superuser access)

```
adb shell
su
mount -o remount,rw /system
cp /sdcard/<NamefromOpenSSLOutput>.0 /system/etc/security/cacerts
chmod 644 /system/etc/security/cacerts/NamefromOpenSSLOutput>.0
chown root:root /system/etc/security/cacerts/NamefromOpenSSLOutput>.0
mount -o remount,ro /system
```

Then we should reboot the device

```
reboot
```

Once restarted if you got to on the Android device (names may vary by version) Setting > Security > Encryption & Credentials > Trusted Credentials > System you should see mitmproxy's certificate listed.


### Methodology

The methodology that Privacy International used to do our analyses is as follows:

All data being transmitted between Facebook and apps is encrypted in transit using Transport Layer
Security (TLS, formally SSL). Our analysis consisted of capturing and decrypting data in transit between
our own device and Facebook’s servers (so called "man-in-the-middle") using the free and open source
software tool called "mitmproxy", an interactive HTTPS proxy. Mitmproxy works by decrypting and
encrypting packets on the fly by masquerading as a remote secure endpoint (in this case Facebook). In
order to make this work, we added mitmproxy's public key to our device as a trusted authority. The data
exists on our local network at time of decryption.

A new Google Account was setup for the sole purpose of this research and a full phone "nandroid" backup
was taken so the device could quickly be returned to a known state, particularly considering that when
some apps are installed and run, they continue to run in the background potentially polluting the results.

All session data that traversed mitmproxy ("flows") where recorded and stored, so they could be analyzed
further.

- All session data that traversed mitmproxy ("flows") where recorded and stored, so they could be
analyzed further, and shared later should the need arise. (in the environment this happens automatically using the scripts provided)
- The screen and interactions where recorded as video using the Androids Developer Bridge (ADB) all
activity that takes place on the screen of the Android device is recorded (you may wish to do this for your own documentation purposes)

Once this was completed and appropriate setting within the phone where selected (pertaining to Wi-Fi,
certificate trust, security such as PIN and screen lockout and developer tools such as showing touches)
a full phone "nandroid" backup was taken so the device could quickly be returned to a known state,
particularly considering that when some apps are installed and run, they continue to run in the
background potentially polluting the results.

- After each wipe the following steps where undertaken
- Connect to a non-intercepting Wi-Fi
- Download the Application from the Google Play Store
- Connect to mitmproxy VM (via Wi-Fi), and create a new flow
- Start Screen Recording using ADB, start screen recording in Virtualbox
- Open the app, and do various activities for up to 320 seconds (if the app requires sign up to use,
Google account created at the start of the process)
- Save screen recording off the phone and stop the flow in mitmproxy
- Reboot to recovery and restore the nandroid backup, ready to restart the process
- Reboot the device

## Troubleshooting

Common issues and their fixes

**Virtualbox installation note for MacOS users**

[MacOS]: If you are using High Sierra or later, you will need to unblock the kernel driver that Virtualbox installs. This can be done in Security & Privacy in the System Preferences, a prompt should appear during installation.

**Starting the environment**

*I'm having issues starting the environment*

If you are having issues starting the environment, check that Virtualbox is installed correctly (see note above). Check that Virtualbox is at least version 6.x. 
>If you are still having issues send an email to chrisw@privacyinternational.org with the [mitmproxy19] as subject line, and I will update this guide with other common issues.

*I'm having issues with display*

The environment was compiled with Virtualbox guest additions, which means that the display should automatically resize. I would suggest using the View -> Virtual Display menu, and setting the virtual display to at least 1920x1080

*The environment is slow or unresponsive*

You may want to check that you can allocate the required resources for the VM, in its default state the VM is allocated 2CPU's and 1024MB's RAM. This means that the minimum requirements are 2CPUs and 2048MBs RAM on the host. This setup won't be particularly performant I would strongly recommend increasing both of these to 4CPUs and 2048MBs RAM if your host system has the capacity


**Using the tools**

*My wireless USB isn't appearing in `iw list` and its definitely connected to the VM*

The environment only has drivers/firmware for Ralink adapters, other adapters (such as Realtek) will require their own drivers to be installed, configuring your specific wireless nic falls outside the scope of this document. Either Google "<WLANChipset> Debian" or contact your vendor.

*I can't see a wireless network called `pi_mitmproxy`*

Check that `hostapd` is running, that the nic is correctly set in the `/etc/hostapd/hostapd.conf` configuration files. You can always start `hostapd` in debug mode

```sudo service hostapd stop; sudo killall hostapd; sleep 4;sudo hostapd -p /etc/hostapd/hostapd.conf```

*My device is looping between connecting and disabled, when I look at the "Wi-Fi" setting in Android*

This is indicative of `dnsmasq` not correctly issuing an IP address. You can restart `dnsmasq`:

`sudo service dnsmasq restart`

It may also be because the wireless nic is not correctly defined in `/etc/network/interfaces/` check that the nic has a valid stanza in that configuration file, then restart networking and dnsmasq

`sudo service networking restart; sudo service dnsmasq restart`

>Note DNSMasq occasionally experiences a race condition with `hostapd`, restarting both services should rectify this.
>`sudo service networking restart; sudo service hostapd restart; sudo service dnsmasq restart`

*My device is connected, but states it has no internet access*

This means either mitmproxy isn't running, or you legitimately have no Internet. If mitmproxy is running, check that you have internet. You can do this by trying to `ping google.com` in terminal, if you are seeing issues/timeouts, reconnect and restart the VM

*mitmproxy says that the certificate is unknown*

*mitmproxy says it can't handle pre http2 connections (and it logging PRI with crosses next to it)*

*I'm using Android Pie (9) or later, and I'm having difficulties*

*I'm trying to connect my device for ADB, but Virtualbox won't recognise it*

*My device is connected, but I can't `adb shell`*

*In `adb shell` command `su` is not found*

