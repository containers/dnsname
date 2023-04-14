# Using the dnsname plugin with Podman

The *dnsname* plugin allows containers to resolve each other by name.  The plugin adds each
container's name to an instance of a dnsmasq server.  The plugin is enabled through adding it to a network's
CNI configuration.  The containers will only be able to resolve each other if they are on the same CNI network.

This tutorial assumes you already have Podman, containernetworking-plugins, and a golang development environment installed.

## Install dnsmasq

Using your package manager, install the *dnsmasq* package.  For Fedora, this would be:
`sudo dnf install dnsmasq`

### AppArmor

If your system uses AppArmor, it can prevent dnsmasq to open the necessary files. To fix this, add the following lines to `/etc/apparmor.d/local/usr.sbin.dnsmasq`:

```
# required by the dnsname plugin in podman
/run/containers/cni/dnsname/*/dnsmasq.conf r,
/run/containers/cni/dnsname/*/addnhosts r,
/run/containers/cni/dnsname/*/pidfile rw,
```

Then reload the main dnsmasq profile:

```
sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.dnsmasq
```

## Build and install

1. Clone this repository.
    ```
    git clone https://github.com/containers/dnsname.git
    ```
2. Build the `dnsname` binary.
    ```
    cd dnsname
    make
    ```
3. Install the plugin into the proper `PREFIX` directory (check `podman network ls`) -- this will install the dnsname plugin into /usr/libexec/cni where
your CNI plugins should already exist
    ```
    make install PREFIX=/usr
    ```

## Configure a CNI network for Podman

1. Create a new network using `podman network create`.  For example, `podman network create foobar` will suffice.

The following example [configuration file](example/foobar.conflist) shows a usable example for Podman.

2. (optional)+The configuration will be automatically enabled for newly created networks via
`podman network create`. If you want to add this feature to an exisiting network add the needed
lines to `/etc/cni/net.d/foobar.conflist` using your favorite editor. For example:

 ```
{
   "cniVersion": "0.4.0",
   "name": "foobar",
   "plugins": [
      ...
      {
         "type": "dnsname",
         "domainName": "dns.podman",
         "capabilities": {
            "aliases": true
         }
      }
   ]
}
 ```

## Example: container name resolution

In this test image, the nginx server will
respond with *podman rulez* on an http request.
**Note**: we use the --network foobar here.

```console
sudo podman run -dt --name web --network foobar quay.io/libpod/alpine_nginx:latest
5139d65d22135e9ecab511559d863754550894a32285befd94dab231017048c2

sudo podman run -it --name client --network foobar quay.io/libpod/alpine_nginx:latest curl http://web.dns.podman/
podman rulez
```

## Enabling name resolution on the default Podman network
After making sure the *dnsplugin* is functioning properly, you can add name resolution to your default Podman
network.  This can be done two different ways:

1. Add the *dnsname* plugin as described in above to your default Podman network.  This default network is
usually `/etc/cni/net.d/87-podman-bridge.conflist`.
