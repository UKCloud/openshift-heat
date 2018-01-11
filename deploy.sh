#!/bin/bash

openshift_openstack_password=$1

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

function determineFloatingIpMethod() {
  if [[ $(grep -q '  haproxy_floating_ip:' environment.yaml ; echo $?) == 0 ]]; then
    sed -e "s/parameters:/parameters:\\`echo -e '\n\r'`  haproxy_floating_ip:\\`echo -e '\n\r'`     type: string/g" openshift-template.yaml > openshift.yaml
    sed -i -e "s/  floatingip_id: { get_resource: haproxy_floating_ip }/  floatingip_id: { get_param: haproxy_floating_ip }/g" openshift.yaml
    sed -i -e "s/    value: { get_attr: \[  haproxy_floating_ip, floating_ip_address \] }/    value: { get_param: haproxy_floating_ip }/g" openshift.yaml
    sed -i -e "s///" openshift.yaml
  else
    sed -e "s/resources:/resources:\\`echo -e '\n\r'`  haproxy_floating_ip:\\`echo -e '\n\r'`    type: OS::Neutron::FloatingIP\\`echo -e '\n\r'`    properties:\\`echo -e '\n\r'`      floating_network: "Internet"\\`echo -e '\n\r'`/g" openshift-template.yaml > openshift.yaml
    sed -i -e "s///" openshift.yaml
  fi
}

function deployHeatStack() {
  openstack stack create -f yaml -t openshift.yaml openshift-$OS_TENANT_NAME \
    -e rhel_reg_creds.yaml \
    -e environment.yaml \
    --parameter time="$(date)" \
    --parameter os_auth_url=$OS_AUTH_URL \
    --parameter os_tenant_id=$OS_TENANT_ID \
    --parameter os_tenant_name=$OS_TENANT_NAME \
    --parameter os_region=$OS_REGION_NAME \
    --parameter openshift_openstack_password=$openshift_openstack_password \
    --wait
}

validateSetup
getPassword
determineFloatingIpMethod
deployHeatStack
