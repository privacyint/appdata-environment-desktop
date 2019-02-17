# Privacy International's data interception environment
`Version: 2.0.3-20190129`

## Background
In December 2018, Privacy International released a report highlighting how Facebook can track you via Android apps even when your not a Facebook user. [@F_Kaltheuner](https://twitter.com/F_kaltheuner) and [@CJFWeatherhead](https://twitter.com/cjfweatherhead) presented the findings of this report at the 35th Chaos Computer Congress (35C3). Privacy International committed to releasing their environment used to conduct this research so as allow others to either repeat or expand on it.

Although the tools themselves are relatively trivial and there are already generic toolkits (such as Kali) that encompass them, this VM is specifically for one purpose, and includes documentation to assist with that purpose, hopefully negating some of the necessity to read forum posts or disparate documentation.

This is a replica of the original environment used to conduct the research, there are a number of reasons why the original environment was unsuitable for redistribution, principally potential issues around licensing due to the use of proprietary drivers. Additionally the original environment was devised in June 2018 and many of tools and features had been subsequently update, the updated software is present in this environment.

## Theory

This toolkit is built around a flaw that exists in the trust paradigm used extensively on the Internet. When secure connections are established such as HTTPS, the client checks against an internal store of "trust anchors" in its "trust store" known as certificate authorities (or CAs for short). CA's exist in most operating systems through a number of methods, predominantly commercial agreements. This toolkit introduces are own CA that we add to the "trust store" which allows us to intercept secure traffic in transit, because the client now trusts this CA too, in addition to the preconfigured ones.

This is where the term man-in-the-middle comes from, as we are sitting between the client and the server in the middle and intercepting and analysing the communication.

## Implementation

Inside this toolkit there are number of components which work together to allow for interception of data in transit. Let us talk through each element and how they work together, then I will discuss the various ways that they can be used

### Virtualbox (6.0.2)

Virtualbox is a free cross-platform Virtual Machine manager, it allows for one operating system to be run inside another by emulating the features of a physical computer virtually. As far as the operating system inside the Virtual Machine is concerned it is running on physical hardware (mostly). The advantage of doing this is that the hardware is abstract and portable, so can be redistributed, it also means that the activity inside the virtual machine is contained and isolated from the real operating system that you use daily.

### Debian (10) (Buster / Unstable)

Debian is a flavour of linux, a unix-like kernel and operating system architecture. Debian Buster is currently the development build for the next major release of the operating system. Buster differs from the previous release (Stretch) in that it incorporates an updated version of Python which eases the installation of mitmproxy, a major component of this toolset

### mitmproxy (4.0.4)

mitmproxy is an open-source proxy (intermediary) server written in Python, it essentially takes connections in on one side, opens them up for analysis and then forwards them on to the other side in full-duplex. Its key feature is that it generates the required certificates in real time so that the incoming connection (from the client), believes that the proxy is the real destination. In the configured environment mitmproxy is configured in "transparent" mode, this means no additional settings need to be changed on the client other than the installation of mitmproxy's certificate.

### dnsmasq (2.80) (`Enabled`)

dnsmasq is a lightweight DNS (domain name service) and DHCP (dynamic-host configuration protocol) server, it serves two purposes, firstly it gives out IP addresses that allow devices to join a network without having them be configured manually this includes setting all the parameters such as DNS server, default route and domain. Secondarily it services DNS requests which involves predominantly turning domain names such as `privacyinternational.org` into IP addresses such as `144.76.205.68`

### hostapd (2.6) (`Disabled`)

hostapd is a configurable 802.11 (Wireless LAN) daemon, it allows wireless devices to be configured in a number of ways. In this toolset it is disabled by default as I don't know what WLAN controller you are using, it does however have a sane default configuration setup and can be easily enabled, more information about this is in the section "Further Usage"

### iptables (1.8.2)

iptables is the de-facto standard firewalling system in many linux based operation systems, it uses a table of human-readable rules to categorise and manipulate traffic through a set of well known networking states. In this toolset it serves two purposes, it feeds traffic from ports 80 (http) and 443 (https) into mitmproxy, it also allows for other connections to be masqueraded so that the VM shall act like a router.

### Component Layout

```

 +----------+  ethernet +-----------+  ethernet  +------------+  WiFi +-----------+
 |  Public  +-----------+VirtualBox +------------+Network     |       |  Android  |
 | Internet |         | |   PI VM   | |          |Access Point| <--+--+Phones WLAN|
 +----------+         | +-----------+ |          +------------+    or +-----------+
                      |       |       | USB/PCI(e)                 |
                      +       |       +---------> [optionally]     |
                   enp0s3     |    enp0s8      Your WLAN adapter <-+
                   (NAT)      |   (Bridged)         (hostapd)
                 [Adapter 1]  +  [Adapter 2]
                          mitmproxy
                           dnsmasq
```

Lets walk through the diagram from left-to-right. The Internet as displayed in the diagram, would be however you usually connect to the internet. I have assumed via ethernet, however this may not be the case. In any case adapter 1 in virtualbox (enp0s3 inside the VM) should be set as a NAT device, this will mean that the VM will use the hosts network connection to gain access to the internet.

The Virtualbox VM should be booted and mitmproxy should be running before trying to connect any downstream devices. There are scripts on the desktop which I will explain in more detail in the usage section.

To the right of the VM is a bridged NIC (Adapter 2 in virtualbox, enp0s8 in the VM), in the shipped configuration this should be bridged to the downstream network (ethernet), which itself should be connected either to the device wanting to be analysed or a wireless access point (itself running in bridged mode).

>**Optionally:** The bridged interface (enp0s8) can be disabled and a WiFi network interface controller (NIC) can be connected directly into VM (via USB or PCI(e)), this is explained in "further usage" section, as this requires a few additional setup steps.

Finally on the far right is the device you want to analyse, this is assumed to be a Android Phone. The following changes will need to be made to device
- The network will need to be changed to that provided by the AP or WLAN NIC
- You will need to install mitmproxy's certificate into the devices trust store, further instructions for this can be found below


## Usage



### Prerequisites

* A Notebook or Desktop, with internet access, capable of running VirtualBox 6.x
* A Device you wish to analyse, in this guide an Android phone is assumed, and it is assumed to be rooted
* A wireless network, the main guide will assume through a bridging access point, the "Further usage" section will talk about USB Dongles as AP's

My suggestions for access points, if you don't have an old router lying around would be:
amzn.com/B073TSK26W

My suggestion for USB Dongles would be:
amzn.com/B00JZFT3VS (they are not fancy, but they do work)

#### Required Changes

As your enviroment and hardware will be different to mine, there are few things worth checking before starting the Virtual Machine.

#### Before starting the VM

**The number of assigned CPU's and quantity of Memory**

You may want to check that you can allocate the required resources for the VM, in its default state the VM is allocated 2CPU's and 1024MB's RAM. This means that the minimum requirements are 2CPUs and 2048MBs RAM on the host. This setup won't be particularly performant I would strongly recommend increasing both of these to 4CPUs and 2048MBs RAM if your host system has the capacity

**Network Controllers**

The network controller (Adapter 2) should be assigned to a real interface that is ultimately connected to the device you want to analyse, this will likely be named differently for you, but should be an ethernet controller

#### Once started

**Login**

The default username and password is:

Username: `privacy` <br />
Password: `international`

**Internet Connectivity**

 You can test this after the VM has booted by opening a browser and seeing if sites like `google.com` load correctly.

 **Desktop Items**

 There are a number of desktop items, most of them linking to configuration files. Below I list the filenames and their purposes

#### Configuring your handset

### Methodology

### Interpreting your data

## Further Usage
