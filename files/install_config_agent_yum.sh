#!/bin/bash
set -x

# on Atomic host os-collect-config runs inside a container which is
# fetched&started in another step
[ -e /run/ostree-booted ] && exit 0


# Log all output to file.
exec > >(tee -a /var/log/bash_script.log) 2>&1

# connect eth1 and use dhcp to get address from neutron network
nmcli d connect eth1

# set UK timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

retry() {
   count=0
   until [ $count -ge 5 ]
   do
      $@ && break  # substitute your command here
      count=$[$count+1]
      sleep 15
   done
}

# register with redhat
retry subscription-manager register --org __rhn_orgid__ --activationkey __rhn_activationkey__

# determine pool ID's for red hat subscriptions
openstackPoolId=$(retry subscription-manager list --available | grep 'Red Hat OpenStack Platform for Service Providers' -A100 | grep -m 1 'Pool ID' | awk '{print $NF}')
openshiftPoolId=$(retry subscription-manager list --available | grep 'Red Hat OpenShift Container Platform for Certified Cloud and Service Providers' -A100 | grep -m 1 'Pool ID' | awk '{print $NF}')

# setup repos & install software packages
retry subscription-manager attach --pool=$openstackPoolId
retry subscription-manager attach --pool=$openshiftPoolId
retry subscription-manager repos --disable=*

retry subscription-manager repos \
        --enable=rhel-7-server-rpms \
        --enable=rhel-7-server-extras-rpms \
        --enable=rhel-7-fast-datapath-rpms \
        --enable=rhel-7-server-openstack-9-rpms \
        --enable=rhel-7-server-openstack-9-director-rpms \
        --enable=rhel-7-server-rh-common-rpms

retry yum install -y \
        os-collect-config \
        python-zaqarclient \
        os-refresh-config \
        os-apply-config \
        openstack-heat-templates \
        python-oslo-log \
        python-psutil \
        ansible

# setup OpenShift repos and install packages required specifically for OpenShift
retry subscription-manager repos --enable=rhel-7-server-ose-__openshift_version__-rpms

retry yum install -y \
        wget \
        git \
        net-tools \
        bind-utils \
        iptables-services \
        bridge-utils \
        bash-completion \
        kexec-tools \
        sos \
        psacct \
        atomic-openshift-utils \
        atomic-openshift-excluder \
        atomic-docker-excluder \
        atomic-openshift-clients
