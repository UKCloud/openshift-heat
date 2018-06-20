#!/bin/bash

multinetwork=$( grep multinetwork: environment.yaml | awk '{print $2}' )
extra_gateway=$( grep extra_gateway: environment.yaml | awk '{print $2}' )
openshift_openstack_password="$1"

function validateSetup() {
  if [[ -z $OS_TENANT_ID ]]; then
    echo -e "\nYou must source your OpenStack RC file so we can access the OpenStack API\n"
    exit 1
  fi
}

function getPassword() {
  if [[ -z $openshift_openstack_password ]]; then
    echo -e "Please provide a password for the OpenStack tenancy OpenShift will be deployed to..."
    read -s openshift_openstack_password
    echo -e "Starting deployment..."
  fi
}

function setupHeatTemplate() {
  ansible-playbook ./setup-heat-templates.yaml \
    --extra-vars "multinetwork=$multinetwork" \
    --extra-vars "extra_gateway=$extra_gateway"
}

function deployHeatStack() {
  openstack stack create -f yaml -t openshift.yaml openshift-$OS_TENANT_NAME \
    -e rhel_reg_creds.yaml \
    -e environment.yaml \
    --parameter multinetwork="$multinetwork" \
    --parameter time="$(date)" \
    --parameter os_auth_url="$OS_AUTH_URL" \
    --parameter os_tenant_id="$OS_TENANT_ID" \
    --parameter os_tenant_name="$OS_TENANT_NAME" \
    --parameter os_region="$OS_REGION_NAME" \
    --parameter openshift_openstack_password="$openshift_openstack_password" \
    --wait
}

function showBastionIp() {
  openstack stack output show openshift-$OS_TENANT_NAME --all
}

validateSetup
getPassword
setupHeatTemplate
deployHeatStack
showBastionIp
