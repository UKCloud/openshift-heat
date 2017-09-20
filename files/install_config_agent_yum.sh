#!/bin/bash
set -eux

# on Atomic host os-collect-config runs inside a container which is
# fetched&started in another step
[ -e /run/ostree-booted ] && exit 0

#!/bin/bash

# Log all output to file.
exec > >(tee -a /var/log/bash_script.log) 2>&1
set -x

#connect eth1 and use dhcp to get address from neutron network
nmcli d connect eth1

#set UK timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# setup repos & install software packages
subscription-manager register --org __rhn_orgid__ --activationkey __rhn_activationkey__
subscription-manager attach --pool=8a85f9875801950c01580c235a322cb4
subscription-manager attach --pool=8a85f9815a3616cf015a36b0439d09ab
subscription-manager repos --disable=*
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-ose-3.5-rpms --enable=rhel-7-fast-datapath-rpms --enable=rhel-7-server-openstack-9-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-7-server-openstack-9-director-rpms
yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion atomic-openshift-utils atomic-openshift-excluder atomic-docker-excluder atomic-openshift-clients

yum -y install os-collect-config python-zaqarclient os-refresh-config os-apply-config openstack-heat-templates python-oslo-log python-psutil ansible
