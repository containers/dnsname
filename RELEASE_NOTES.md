# Release Notes

## 1.3.1
- Fixed an issue where an incorrect use of `LDFLAGS` made `dnsname` unable to build in some packaging systems.

## 1.3.0
- Fixed a bug where errors when removing a container from `dnsname` could cause CNI to fail to clean up iptables rules for the container.
- Fixed a bug where `dnsname` would never remove unused configuration files for networks that no longer had containers present.
- If errors occur when running `dnsmasq`, the full error message is now displayed for debugging.
- The version number of `dnsname` is now displayed correctly.

## 1.2.0
- DNS Search domains required to use the `dnsname` plugin are now returned in the CNI response.

## 1.1.1
- Fixed a bug where network aliases support was nonfunctional.

## 1.1.0
- Added support for network aliases - multiple names for the same container.

## 1.0.0
- Initial release