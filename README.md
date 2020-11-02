# dnsname plugin

## Overview

This plugin sets up the use of dnsmasq on a given CNI network so that Pods can resolve each other by name.  When configured,
the pod and its IP address are added to a network specific hosts file that dnsmasq reads in.  Similarly, when a pod
is removed from the network, it will remove the entry from the hosts file.  Each CNI network will have its own dnsmasq
instance.

The *dnsname* plugin was specifically designed for the [Podman](https://github.com/containers/podman) container engine.
Follow the [mini-tutorial](README_PODMAN.md) to use it with Podman.


## Usage
The dnsname plugin can be enabled in the cni network configuration file.

```
{
    "cniVersion": "0.4.0",
    "name": "cni-bridge-network",
    "plugins": [
      {
        "type": "bridge",
        "bridge": "cni0",
        ...
        }
      },
      {
        "type": "dnsname",
        "domainName": "foobar.com",
        "capabilities": {
            "aliases": true
        }
      }
    ]
}
```

## DNSMasq configuration files
The dnsmasq service and its configuration files are considered to be very fluid and are not meant to survive a system
reboot.  Therefore, files are stored in `/run/containers/cni/dnsname`, or under `$XDG_RUNTIME_DIR/containers/cni/dnsname` if
`XDG_RUNTIME_DIR` is specified.  The plugin knows to recreate the necessary files if it detects they are not present.

##  DNSMasq default configuration
Much like the implementation of DNSMasq for libvirt, this plugin will only set up dnsmasq to listen on the network
interfaces associated with the CNI network.  The DNSMasq services are not configured or managed by systemd but rather
only by the plugin itself.

## Network aliases
The dnsname plugin is capable of not only adding the container name for DNS resolution but also adding network aliases. These
aliases are also added to the DNSMasq host file.

## Reporting issues
If you are using dnsname code compiled directly from github, then reporting bugs and problem to the dnsname github issues tracker
is appropriate.  In the case that you are using code compiled and provided by a Linux distribution, you should file the problem
with their appropriate bug tracker (bugzilla/trackpad).
