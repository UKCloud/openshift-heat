#!/bin/bash
set -x

# on Atomic host os-collect-config runs inside a container which is
# fetched&started in another step
[ -e /run/ostree-booted ] && exit 0


# Log all output to file.
exec > >(tee -a /var/log/bash_script.log) 2>&1

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
# get and install katello package from our satellite server
if [[ "__satellite_deploy__" = True ]] 
then
	retry rpm -Uvh http://__satellite_fqdn__/pub/katello-ca-consumer-latest.noarch.rpm
fi

# register with redhat
retry subscription-manager register --org __rhn_orgid__ --activationkey __rhn_activationkey__

# install katello agent from specific repo and then disable
if [[ "__satellite_deploy__" = True ]]
then
        subscription-manager repos --enable=rhel-7-server-satellite-tools-6.5-rpms
        yum install -y katello-agent
fi

# determine pool ID's for red hat subscriptions
openstackPoolId=$(subscription-manager list --available --matches='Red Hat OpenStack Platform for Service Providers' | awk '/Pool ID/ {print $NF}')
openshiftPoolId=$(subscription-manager list --available --matches='Red Hat OpenShift Container Platform for Certified Cloud and Service Providers' | awk '/Pool ID/ {print $NF}')

# setup repos & install software packages
retry subscription-manager attach --pool=$openstackPoolId
retry subscription-manager attach --pool=$openshiftPoolId
retry subscription-manager repos --disable=*

retry subscription-manager repos \
        --enable=rhel-7-server-rpms \
        --enable=rhel-7-server-extras-rpms \
        --enable=rhel-7-fast-datapath-rpms \
        --enable=rhel-7-server-openstack-10-rpms \
        --enable=rhel-7-server-openstack-12-tools-rpms \
        --enable=rhel-7-server-rh-common-rpms \
        --enable=rhel-7-server-ansible-2.6-rpms \
        --enable=rhel-7-server-satellite-tools-6.5-rpms

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
        openshift-ansible \
        atomic-openshift-excluder \
        atomic-openshift-clients \
        vim \
        tmux

retry systemctl enable rhsmcertd --now
