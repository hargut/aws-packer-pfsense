# Purpose

Build and import a pfSense image for usage on AWS using Hashicorp Packer with Virtualbox or KVM backend.

# Information
It is not intended that the repository will see any updates, bugs fixes or further adaption to new pfSense versions. Feel free to do whatever you like with it in your own fork.

There are areas in the repository which should be considered as a draft, not finished or rushed.

# License
Unlicense

# Instructions
* Download a copy of the pfSense image `pfSense-CE-2.4.2-RELEASE-amd64.iso` to the `input/` directory and then run `packer build pfsenese-<qemu|vbox>.json`.
* `remote-qemu-vnc.sh|remote-vbox-rdp.sh` can be used to view the build process. Do not manually press keys during viewing.
* Created images are placed in the `output-<qemu|vbox>/` directory.
* `aws/import-role/import-role.sh` contains the required roles for the AWS import processes. Policies need to be modified to match your AWS account.
* `aws/ec2-snapshot.sh` is prepeared for importing the created image to AWS. Need to be adjusted to meet your configuration.
* Create an EC2 Instance from the imported image. Before starting it, attach a second network interface (ENI) to the instance, otherwise pfSense will not come up properly.

Depending on the build machine and available resources it might be necessary to adjust timings in the jsons for the keystrokes. This files build nicely on a NVME backed setup.


# Configuration
This pfSense config.xml contains the following modifications in `config/config.xml` compared to stock config:

  * disabled dhcpd and dhcpdv6 (on LAN interface)
  * Webinterface listens on port 7373
  * OpenSSH listens on port 6736
  * allow Webinterface and OpenSSH traffic on WAN interface from ANY source 
  * allow private network connections on WAN interface (for packer & testing)
  * disable HTTP_REFERERCHECK for accessing WebInterface through ANY ip/dns
  * enabled login on console

As soon as your instance is up and running, __update the settings to suit your needs__!