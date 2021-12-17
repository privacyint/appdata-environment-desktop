![PI Logo Roundel Flat RGB Solid](https://user-images.githubusercontent.com/58432995/146573769-fc51d7ff-fad3-469f-bba8-39cd12af23fb.png)


# Privacy International's data interception environment
`Version: 2.1.2-20190730`

- [Privacy International's data interception environment](#privacy-internationals-data-interception-environment)
  - [Quick Start Guide](#quick-start-guide)
    - [Step 0 - Prerequisites](#prerequisites-as-this-is-a-quick-start-guide)
    - [Step 1 - Download](#step-1---download)
    - [Step 2 - Add a device](#step-2---Adding-a-device)
    - [Step 3 - Downloading your apps](#step-3---downloading-your-apps)
    - [Step 4 - Initialising](#step-4---Initialising)
    - [Step 5 - Setup](#step-5---setup-interception)
    - [Step 6 - Start collecting and analysing](#step6---start-collecting-and-analysing)
    - [Step 7 - Start testing apps](#step7---start-testing-apps)
    - [Notes on Certificate pinning](#notes-on-certificate-pinning)
  - [Background](#background)
  - [Theory](#theory)
  - [Implementation](#implementation)
    - [Virtualbox (6.0.4)](#virtualbox-604)
    - [Debian 10 (Buster)](#debian-10-buster)
    - [mitmproxy (4.0.4)](#mitmproxy-404)
    - [dnsmasq (2.80) (`Enabled` by default)](#dnsmasq-280-enabled)
    - [hostapd (2.6) (`Disabled` by default)](#hostapd-26-disabled)
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
 - [Acknowledgements](#acknowledgements)

## Quick Start Guide

> For those who just want to get analysing

### Prerequisites (as this is a quick start guide):

- VirtualBox Version 6.1 or later Installed (https://www.virtualbox.org/wiki/Downloads)
- Genymotion Installed (https://www.genymotion.com/)
- Unarchival software (such as 7Zip, Peazip, Keka, Ark etc)
- Internet Connectivity
- Some experience of UNIX-like operating systems (particularly those using systemd)
- Some experience with Android and the Android Developer Bridge (ADB)
- Web browser
- If you are using a physical phone: an Android Handset that is rooted and has ADB enabled, running Oreo (Android 8.X) or earlier

### Step 1 - Download

Download the latest release of the Data Interception Environment (DIE) (https://github.com/privacyint/appdata-environment-desktop/releases) It’s a multi-part archive – so you’ll need to download all the parts. They are in OVA format, which means you will need Oracle’s VirtualBox to open them. They can be extracted with any of the unarchival software mentioned above. 

### Step 2 - Adding a device

Open Genymotion and add a device – there are a large selection of phones that you can choose from. For this tutorial we’re going to set up a virtual Pixel phone running Android 8.1. Once you pick the phone you want to choose, select it. 

### Step 3 - Downloading your apps

Sign in to a Google account, this will allow you to access the Play Store. You can then download any apps you want to test. We’d also strongly recommend installing a browser, such as Google Chrome. 

### Step 4 - Initialising

Once the OVA is extracted double click on it, which will open it in VirtualBox. Some information about the DIE will pop up, click Import, then read and agree to the license terms.

Start the Data Interception Environment. A menu should pop up – this includes all the key set features that you might want to use. This This includes an option to configure a wireless adaptor so you can connect a real phone to the environment. As part of this you may wish to enable hostapd, which is a wireless access point daemon. You can also run an APK through apk-mitm, which allows it to be decompiled so you can remove certificate pinning. The key option here is to start mitmproxy, which allows you to wirelessly intercept secure sessions – which is the option you will likely use most often. There is also an option for showing the documentation. And you can update the environment through the link provided, although this functionality is relatively experimental.

### Step 5 - Setup interception

Once you have all the apps you wanted to test installed, shut down the virtual phone and go to the settings in VirtualBox for the phone you’re using. The key one to change here is to change the network adaptor, on adaptor two, from NAT to an internal network. We called it ‘iNet’. You can leave the rest of the settings as they were. You can leave the rest of the settings as they were. You'll be able to see that the environment also has a secondary adaptor, also connected to iNET.

The reason for changing this network interface is so that all the data will be transferred across the internal network, so that the DIE will be able to intercept them.

Start the phone through Genymotion. If you start the phone through VirtualBox the phone will start but you won’t be able to use the interface. Once the phone has started, look at the network settings on the handset, it should be connected to Android wifi. And it should say, "Connected. No internet." This is a good sign.

You should, hopefully, see that it has an IP address starting 100.64 which means that the environment has set the IP rather than it being coming from a localized NAT device, as they usually start 192.168. 56. The environment always gives the IPs in the 100.64.s32 range.

### Step 6 - Start collecting and analysing

Start Mitmproxy. Now open the web viewer in the phone and look at mitmproxy – you should see the request coming in on the data interception environment. You can also summon instructions there as to how to set up the device, including information around if you want to use mitmproxy with devices running API level 24 or higher.

Open your web browser on the virtual phone and go to mitm.it and download the certificate. Once the certificate is downloaded it will appear in the download section of the files app.

Start your local terminal so you can install certificates into the system root store as outlined in the documentation on the GitHub and inside the DIE.

Run ADB devices to see which devices are available to connect to. There’s only one device available, which is the Genymotion device.

Then start ADB shell, which will allow you to access the local console of the Genymotion phone.

If you change the directory to SD card download and list the directory, you should see the mitmproxy certificate listed there. For the time being you can close mitmproxy as you don’t need it.

Copy and paste the open SSL command from below or from the local documentation into the local console in the VM running the DIE.

sudo openssl x509 -inform PEM -subject_hash_old -in /root/.mitmproxy/mitmproxy-ca-cert.pem | head -1

This will return the name you will later need to give the file in Android for it to recognize the certificate authority.  This is how you’re going to become the local administrator on the virtual device.

When we copied the open SSL command into the console, we got the output C8750F0D. This is the name we'll have to give the certificate later when we copy it into the system root store on the Genymotion device.

Go back to your local console, which should still be running ADB shell

First execute su to become super user on the device, i.e. the local administrator.

Remount the partition system folder. This allows us to modify system data, which is usually read only.

mount -o remount,rw /system

Copy the certificate from the downloads folder into the systems certificate folder.  You can use this in the console: cp /sdcard/Download/mitmproxy-ca-cert.pem /system/etc/security/cacerts/<NamefromOpenSSLOutput>.0

When copying the file, you need to use the name you retrieved earlier running from running the open SSL command, for us that would be C8750F0D. And then the extension is .0 – making the full title C8750F0D.0

You now need to change the file permissions, so copy this into the console: chmod 644 /system/etc/security/cacerts/<NamefromOpenSSLOutput>.0

And again, type in the certificate's name to replace <NamefromOpenSSLOutput>.

You also need to change who the file belongs to and make sure it belongs to root: chown root:root /system/etc/security/cacerts/NamefromOpenSSLOutput>.0

Now remount the file system read only: mount -o remount,ro /system

Reboot the device.

Exit the console and restart mitmproxy. You should see on the left that the device is now rebooting. Open mitmproxy in the web browser – you should be able to see a large amount of data that’s being collected. This is because as the device boots up it checks for internet access.

Look at the WiFi settings, it should now just say ‘connected’, unlike before where it said ‘connected, no internet’.

You can check that mitmproxy is installed correctly, by opening your browser and going to a website. You can go to the list of things being intercepted by mitmproxy and you’ll be able to see all the requests being made to the website.

Then, if click on the status bar, you should see that the certificate being presented is from mitmproxy, and if you look at the certificate information you should see that the assurer is mitmproxy.

Just for the sake of completeness, go to Privacy International's website not on the phone and you should see your browser isn't being intercepted. Again, look at the certificate information - this certificate is usually issued by DigiSure, Inc. If you look at the certificate it even includes all the information about PI.

You can now close your browser, and all the other applications you had open – you don’t need any at the moment.

Open the settings app and do a search for certificates and look at the trusted credentials section. Displays, which displays the trusted CAs and click on the system section. You can scroll down and see that the mitmproxy is a trusted system root.

Close mitmproxy and start a new session. Every time mitmproxy is restarted, the previous capture is saved to disk. If you head back to mitmproxy's webpage. You should see the capture is now clear as a new capture has been started. We would recommend always starting a new capture with every different application you wish to test.
  
### Step 7 - Start testing apps
  
Open the first app you want to test.

If you click on ‘request’, you should be able to see what the original request was and what the response was.

For example, this is Google Firebase and we can see what token was used to authenticate with and what response was given for that Firebase installation.

In the bottom right-hand corner you can also find out information such as the SDK conversion of this version of Firebase Analytics and you can see things like remote requests. You can also see downloaded imagery such as that displayed in the top portion of the Met Office app – in this case the logo.

As you click things in the app, such as accepting the privacy policy, you should see more connections being made – some will be content, others metrics, advertising, or other third party services.

The DIE can tell you what’s being sent from your device and where to, but it cannot tell you want the company is doing with that information, what processing they are doing, or whether they are sending that data on to third parties. Above you can see what the app is sending to Facebook, but it can’t tell you what Facebook is doing with that information.

When you’re done with the app – you can close your mitmproxy session. All captures are stored locally in privacy’s home folder, so the most recent captures can all be reloaded. If you want to analyse another app – start a new mitmproxy session. 

### A note on certificate pinning
  
One of the new features of the data interception environment is the inclusion of APK MITM, which allows the removal of certificate pins. Some large apps, like Facebook, banking apps, Twitter and some of the other apps that have large numbers of users, use a technique called certificate pinning, which means that they expect certain certificates to be presented by the remote side by making a connection. And if the, the certificate differs, then they will not make the secured connection.

What APK MITM allows is the removal of those pins so you can continue to do analysis in the data interception environment.
  
## Background
In December 2018, [Privacy International](https://privacyinternational.org) released a [report](https://privacyinternational.org/report/2647/how-apps-android-share-data-facebook-report) highlighting how [Facebook can track you via Android apps even when you're not a Facebook user](https://privacyinternational.org/appdata). [Frederike Kaltheuner](https://twitter.com/F_kaltheuner) and [Christopher Weatherhead](https://twitter.com/cjfweatherhead) presented the findings of this report at the [35th Chaos Computer Congress (35C3)](https://media.ccc.de/v/35c3-9941-how_facebook_tracks_you_on_android). Privacy International committed during that talk to releasing the environment used to conduct this research to allow others to either repeat or expand upon it.

Although the tools themselves are relatively trivial and there are already generic toolkits (such as Kali) that encompass them, this Virtual Machine is specifically for one purpose, and includes documentation to assist with that purpose. This hopefully negates some of the necessity to read various forum posts or disparate documentation.

NB: This is a *replica* of the original environment used to conduct the research. There are a number of reasons why the original environment was unsuitable for redistribution, principally potential issues around licensing due to the use of proprietary drivers. In addition, the original environment was devised in June 2018 and many of tools and features have subsequently been updated. The updated software is present in this environment.

## Theory

This toolkit is built around a flaw that exists in the trust paradigm used extensively on the Internet. When secure connections such as HTTPS are established, the client checks against an internal store of "trust anchors" in its "trust store" - known as certificate authorities (*CAs* for short). CAs are trusted in most operating systems through a number of methods, predominantly via commercial agreements.

This toolkit introduces a CA that we add to the "trust store" (see step 5 and 6 above), allowing us to intercept secure traffic in transit as the client now trusts this CA in addition to the preconfigured ones.

This is where the term *man-in-the-middle* (MITM) comes from, as we are inserting ourselves between the client and the server, intercepting and analysing any communications between them.

## Implementation

Inside this toolkit there are number of components which work together to allow for interception of data in transit.

Let's talk through each element and how they work together, then we will discuss the various ways that they can be used.

### Virtualbox (6.0.4)

Virtualbox is a free (libre & gratis), cross-platform Virtual Machine manager. It allows for one operating system to be run inside another by emulating the features of a physical computer virtually.

As far as the operating system inside the Virtual Machine is concerned it is running on physical hardware (mostly). The advantage of doing this is that any physical hardware from the host is abstracted and the software inside is then portable, so can be redistributed.

It also means that any activity inside the virtual machine is contained and isolated from the real operating system that you use on the host.

### Debian 10 (Buster)

Debian is a flavour of GNU/Linux, a UNIX-like Kernel and operating system architecture.

### mitmproxy (4.0.4)

mitmproxy is an open-source proxy (intermediary) server written in Python.

In essence, it takes connections in on one side, opens them up for analysis, and then forwards them to the other side in full-duplex. Its key feature is that it generates any required certificates in real-time.

This ensures that the incoming connection (from the client), believes that the proxy is the real destination. In this pre-configured environment mitmproxy is configured in "transparent" mode. This means no additional settings need to be changed on the client, other than the installation of mitmproxy's certificate.

### dnsmasq (2.80) (`Enabled`)

dnsmasq is a lightweight DNS (domain name service) and DHCP (dynamic-host configuration protocol) server.

It serves two purposes;
1. It gives out IP addresses, allowing devices to join a given network without having to manually configure network-specific settings such as DNS server, default route and domain.
2. It services DNS requests; this predominantly involves turning domain names such as `privacyinternational.org` into IP addresses such as `144.76.205.68`

### hostapd (2.6) (`Disabled`)

hostapd is a configurable 802.11 (Wireless LAN) daemon, which allows wireless devices to be configured in a number of ways.

In this toolset it is disabled by default as we don't know what WLAN controller you are using. It does, however, have a sane default configuration, and can be easily enabled.

### iptables (1.8.2)

iptables is the de-facto standard firewalling system in many Linux-based operating systems.

It uses a table of human-readable rules to categorise and manipulate traffic through a set of well known networking states.

In this toolset it serves two purposes
1. It feeds traffic from ports 80 (http) and 443 (https) into mitmproxy
2. It also allows for other connections to be masqueraded so that the VM acts like a router.

### Component Layout

```
+----------+          +-------------------------+             +--------------+
|  Public  +----------+  Privacy International  +-------------+Android Device|
| Internet |         ||  MitmProxy Environment  ||  Wireless: |with mitm cert|
+----------+         ||        VirtualBox       ||pi_mitmproxy+--------------+
               enp0s3+---------------------------+USB WiFi
                (NAT)                             Dongle

```

Let's walk through the diagram from left-to-right.

- The Internet as displayed in the diagram would be which ever way you usually connect to the internet.
- *Adapter 1* in virtualbox (*enp0s3* inside the VM) should be set as a NAT device. This will mean the VM will use the host's network connection to gain access to the internet without requiring any other configuration within the guest.
- The Virtualbox VM should be booted and mitmproxy should be running before trying to connect any downstream devices. There are scripts on the desktop which are explained in more detail in the [usage section](#once-started).
- To the right of the VM is a wireless NIC (we assume a USB dongle). In the shipped configuration this should be disabled, and must be configured before attempting to run mitmproxy. It will host the Wireless network `pi_mitmproxy`
- Finally, on the far right is the device you want to analyse. This is assumed to be an Android Phone. The following changes will need to be made to your device:
-- It must be connected to the network provided by the WLAN NIC (`pi_mitmproxy`)
-- You will need to install mitmproxy's certificate into the devices trust store. Further instructions for this can be found below.

## Usage

### Prerequisites

* A Notebook or Desktop, with internet access, capable of running VirtualBox 6.x
* A Device you wish to analyse. In this guide an Android phone is assumed, and furthermore, it is assumed to be rooted
* A wireless USB Dongle. The main guide will assume a Ralink based one, as installation and configuration of the multitude of wireless network adapters falls outside the scope of this guide.

Our suggestion for USB Dongles is the following:

* [https://www.amazon.com/s?k=Ralink+5370](https://www.amazon.com/s?k=Ralink+5370) (they are not fancy, but they do work) (search amazon for ralink rt5370 in your own country)

#### Required Changes

As your local environment and hardware will be different to that used by Privacy International, there are few things worth checking before starting the Virtual Machine.

#### Before starting the VM

**The number of assigned CPUs and quantity of RAM**

You may want to check that you can allocate the required resources for the VM.

In its default state the VM is allocated 2 CPUs, and 1024 MBs RAM. This means the minimum requirements for your host computer is a dual-core processor and 2048MBs RAM. However, this setup won't be particularly performant and we **strongly** recommend increasing both of these to 4 CPUs and 2048 MBs RAM if your host system has the capacity.

**Network Controllers**

You should check that your Wireless NIC is correctly connected to the Virtual Machine. It's best to do this before trying to boot the VM!

#### Once started

**Internet Connectivity**

 You can test this after the VM has booted by opening a browser and seeing if sites like `privacyinternational.org` load correctly.

**Desktop Items**

 There are a number of desktop items, most of them linking to configuration files. Below is a list of the filenames and their purposes
 
 ```
- LICENSE.md                   - GPL 3.0 Licence
- README.md                    - This Readme
- administer_service.sh        - A graphical user interface for managing systemd services
- change_dhcp_settings.sh	     - An editor for `/etc/dnsmasq.conf`
- change_network_interfaces.sh - An editor for `/etc/network/interfaces`
- change_sources_list.sh       - An editor for `/etc/apt/sources.list`
- change_wificonfig.sh         - An editor for `/etc/hostapd/hostapd.conf`
- mitmproxy_start.sh           - A script to start mitmproxy (mitmweb)
- mitmproxy_stop.sh            - A script to terminate (all) mitmproxy's
- change_wireless_interface.sh - A script to configure wireless interfaces automatically
- mitmproxy_start-nohttp2.sh   - A script to start mitmproxy (mitmweb) without http2 support, (mitigates some Android Bugs)
- mitmproxy_start-iOS.sh .     - A script to start mitmproxy (mitmweb) non-transparently, so that iOS devices can be intercepted
```

> Note: We would STRONGLY recommend clicking the "Execute in Terminal" option when executing any of these scripts

**In the browser** (Firefox)

In the browser there are four bookmarks

- Manual - This Document (Rendered)
- MitMProxy - A link to the local mitmweb instance, frontend for mitmproxy
- Jeroenhd's Excellent Guide to installing Certificates in Android Nougat and later
- mitmproxy Documentation - A link to the official documentation for mitmproxy

**Workflow**

1. Once the VM is started we suggest reading this manual in full!

2. Run `change_wireless_interface.sh` from the Desktop and ensure that your wireless network interface is correctly configured.

3. Enable `hostapd` by running the following command in a terminal ```sudo service systemctl enable hostapd```

4. We then recommend restarting the Virtual Machine. If you are still in terminal window, you can do this with the following command: ```sudo shutdown -r now```

5. Once the machine is restarted you should be ready to do analysis. To do this, start mitmproxy using the ```mitmproxy_start.sh``` script on the desktop

6. Once you have captured data, you can use ```mitmproxy_stop.sh``` to end the mitmproxy process. Your data will be saved in a `flow-*.cap` file in `/home/privacy/`

#### Configuring your handset

Google changed the way the certificate store works in Android Nougat, please follow [this guide to correctly](https://blog.jeroenhd.nl/article/android-7-nougat-and-certificate-authorities) install mitmproxy's certificate on your device.

If you are using earlier versions of Android, you should be able to visit mitm.it once connected to your mitmproxy access point, and install the certificate directly. The abridged steps for installing on Nougat and later can be found in [Step 6 - Notes for Android Nougat or Later](#step-6---android-nougat-or-later).

### Methodology

The methodology Privacy International used to do our analyses is as follows:

- All data being transmitted between Facebook and apps is encrypted in transit using Transport Layer Security (*TLS*, formerly - and still widely referred to as - *SSL*).
- Our analysis consisted of capturing and decrypting data in transit between our own device and Facebook’s servers (so called "man-in-the-middle") using the free and open source software tool "mitmproxy", an interactive HTTPS proxy.
- Mitmproxy works by decrypting and re-encrypting packets on-the-fly by masquerading as a remote secure endpoint (in this case Facebook).
- In order to make this work, we added mitmproxy's public key to our device as a trusted authority. **All data exists on our local network at time of decryption.**
- The Android handset used was running a "pure" (unadulterated) version of Android, connected to a new Google Account set up for the sole purpose of this research.
- Once the device was set up with the appropriate settings (i.e. Wi-Fi, certificate trust, security such as PIN and screen lockout, and developer tools such as showing touches) a full phone "nandroid" backup was taken. This ensured the device could quickly be returned to a known state. This is particularly important as considering that when some apps are installed and run, they continue to run in the background potentially polluting the results. 

After each nandroid restoration, the following steps were undertaken:
1. Connect to a non-intercepting Wi-Fi
2. Download the Application from the Google Play Store
3. Connect to mitmproxy VM (via Wi-Fi), and create a new flow
4. Start Screen Recording using ADB, start screen recording in Virtualbox
5. Open the app, and do various activities for up to 320 seconds (if the app requires sign up to use, a new Google account was created at the start of the process)
6. Save screen recording off the phone and stop the flow in mitmproxy
7. Reboot to recovery and restore the nandroid backup, ready to restart the process
8. Reboot the device

Details of the analysis were recorded using the following methods:

- All session data that traversed mitmproxy ("flows") were recorded and stored, so they could be further analysed, and shared later should the need arise (in the environment this happens automatically using the scripts provided)
- All activities and interactions on the screen were recorded as video using Android's Developer Bridge (ADB) screenrecord (you may wish to do this for your own documentation purposes)

## Troubleshooting

Common issues and their fixes

**Virtualbox installation note for MacOS users**

[MacOS]: If you are using High Sierra or later, you will need to unblock the kernel driver that Virtualbox installs. This can be done in Security & Privacy in the System Preferences, a prompt should appear during installation.

**Starting the environment**

*I'm having issues starting the environment*

If you are having issues starting the environment, check that Virtualbox is installed correctly (see note above). Check that Virtualbox is at least version 6.x. 
>If you are still having problems, create an issue on the github tracker.

*I'm having issues with display*

The environment was compiled with Virtualbox guest additions, which means that the display should automatically resize. We suggest using the View -> Virtual Display menu, and setting the virtual display to at least 1920x1080

*The environment is slow or unresponsive*

You may want to check that you can allocate the required resources for the VM, in its default state the VM is allocated 2CPUs and 1024MBs RAM. This means that the minimum requirements are a dual-core host, with 2048MBs RAM. This setup won't be particularly performant, so we strongly recommend increasing both of these to 4 CPUs and 2048 MBs RAM if your host system has the capacity.

*The Firefox window that opens states "Internal Server Error"*

The virtual machine didn't have internet access at startup. This is a non critical error, it just means that the documentation won't be displayed in an aesthetically pleasing way. The documentation can still be opened by using leafpad (or any other text editor) with the README.md on the desktop.

**Using the tools**

*My wireless USB isn't appearing in `iw list` and its definitely connected to the VM*

The environment only has drivers/firmware for Ralink adapters, other adapters (such as Realtek) will require their own drivers to be installed, configuring your specific wireless nic falls outside the scope of this document. Either Google `<WLANChipset> Debian` or contact your vendor.

*I can't see a wireless network called `pi_mitmproxy`*

Check that `hostapd` is running, that the nic is correctly set in the `/etc/hostapd/hostapd.conf` configuration files. You can always start `hostapd` in debug mode using this command:

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

*mitmproxy says `Client Handshake failed. The client may not trust the proxy's certificate`*

The certificate has not been installed on your handset correctly, please see: [Android Nougat or Later Certificate installation](#step-6---android-nougat-or-later)

*mitmproxy says `Initiating HTTP/2 connections with prior knowledge are currently not supported `*

This is a known issue with mitmproxy and recent versions of Android, the IPs being connected to appear to belong to Google. See [this](https://github.com/mitmproxy/mitmproxy/issues/3362) Github issue for more detail

*I'm using Android Pie (9) or later, and I'm having difficulties*

You may experience issues with Android Pie, as it supports TLS 1.3 which has mitigations against man-in-the-middle. Some providers (like Facebook) won't negotiate a connection if there is a man-in-the-middle detected

*I'm trying to connect my device for ADB, but Virtualbox won't recognise it*

Modern phones that use USB-C type connectors may not have backwards support for USB 1.1 that ships by default in Virtualbox. You may need to install the [Virtualbox extension pack](https://www.virtualbox.org/wiki/Downloads) (if you are able to comply with the licence) and configure USB 3.0 in the VM's settings.

*My device is connected, but I can't `adb shell`*

Make sure that USB Debugging is enabled (this may involve enabling developer mode on your device). If USB Debugging is enabled, check that your device is connect in "File Transfer", "MTP" or "PTP" mode (some devices don't allow the bridge to function in "USB Charge only" mode)

*In `adb shell` command `su` is not found*

Your device hasn't been "rooted", make sure your device is "rooted" by searching for appropriate documentation online. PI accepts no liability for a device becoming inoperable or data loss due to any rooting process.

## Acknowledgements

Privacy International would like to thank all the contributors to the Open Source projects used in this environment.

Privacy International would also like to thank:

- The 35th Chaos Congress (35C3) and Chaos Computer Club (CCC) - for their help and support.
- [Exodus Privacy](https://exodus-privacy.eu.org/en/)- For their original research and tools
- [Mobilsicher.de](https://mobilsicher.de/) - For their research
- Frederike Kaltheuner for her support in this research

**This document was contributed to by:**

From Privacy International:

Christopher Weatherhead, Eliot Bendinelli, Ed Geraghty and Eva Blum-Dumontet


Further pull requests will be accepted

---

Privacy International is committed to fighting for the right to privacy across the world - but we need your support.

[Individual donations are incredibly important to us, and allow us to fund work like this](https://support.privacyinternational.org)
