#!/bin/bash

if [[ -z $(grep worker_scale environment.yaml) ]] ; then
    echo "Edit environment.yaml and specify the new number of workers in 'worker_scale', then uncomment it."
    echo "  # worker_scale: 3" >> environment.yaml
    exit
fi

if [[ -z $OS_TENANT_ID ]] ; then
    echo "\nYou must source your OpenStackRC file first\n"
    exit 1
fi

echo -e "Please provide a password for the OpenStack tenancy OpenShift will be deployed to..."
read -s openshift_openstack_password

echo "UPSCALING YOUR OPENSHIFT CLOUD..."
openstack stack update -f yaml -t openshift.yaml openshift \
    -e rhel_reg_creds.yaml \
    -e environment.yaml \
    --parameter time="$(date)" \
    --parameter os_auth_url=$OS_AUTH_URL \
    --parameter os_tenant_id=$OS_TENANT_ID \
    --parameter os_tenant_name=$OS_TENANT_NAME \
    --parameter os_region=$OS_REGION_NAME \
    --parameter openshift_openstack_password=$openshift_openstack_password \
    --wait

