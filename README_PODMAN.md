# Using the dnsname plugin with Podman

The *dnsname* plugin allows containers to resolve each other by name.  The plugin adds each
container's name to an instance of a dnsmasq server.  The plugin is enabled through adding it to a network's
CNI configuration.  The containers will only be able to resolve each other if they are on the same CNI network.

**Note**: This plugin does not work with rootless containers.

This tutorial assumes you already have Podman, containernetworking-plugins, and a golang development environment installed.

## Install dnsmasq

Using your package manager, install the *dnsmasq* package.  For Fedora, this would be:
`sudo dnf install dnsmasq`


## Build and install

1. using git, clone the *github.com/containers/dnsname* repository.
2. make install PREFIX=/usr -- this will install the dnsname plugin into /usr/libexec/cni where your CNI plugins
should already exist.

## Configure a CNI network for Podman

1. Create a new network using `podman network create`.  For example, `podman network create foobar` will suffice.

The following example [configuration file](example/cni-podman1.conflist) shows a usable example for Podman.

## Example: container name resolution

1. sudo podman run -dt --name web --network foobar quay.io/libpod/alpine_nginx:latest
    5139d65d22135e9ecab511559d863754550894a32285befd94dab231017048c2

    Note: we use the --network foobar here. Also, in this test image, the nginx server will respond with
    *podman rulez* on an http request.
2. sudo podman run -it --name client --network cni-podman1 quay.io/libpod/alpine_nginx:latest curl http://web/
podman rulez


## Enabling name resolution on the default Podman network
After making sure the *dnsplugin* is functioning properly, you can add name resolution to your default Podman
network.  This can be done two different ways:

1. Add the *dnsname* plugin as described in above to your default Podman network.  This default network is
usually `/etc/cni/net.d/87-podman-bridge.conflist`.

2. Add a new network as described above and then edit `/etc/containers/libpod.conf` and change the
`cni_default_network` key to your network name.
