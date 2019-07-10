#!/bin/bash

# Usage:
#  deploy.sh [password]
#
#  password is the password for the OpenStack tenancy for this cluster
#
#  If the password is not supplied, the user will be prompted for it.
#  (this prevents the password being stored in your history, but still
#  allows scripted execution in pipelines to work)

openshift_openstack_password="$1"

multinetwork=$(python -c "import yaml;d=yaml.load(open('environment.yaml'));print(d['parameter_defaults']['multinetwork'])" |
    tr '[:upper:]' '[:lower:]')

extra_gateway=$(python -c "import yaml;d=yaml.load(open('environment.yaml'));print(d['parameter_defaults']['deploy_extra_gateway'])" |
   tr '[:upper:]' '[:lower:]')

if [[ $multinetwork == true ]]; then
  purpose_ident=$(python -c "import yaml;d=yaml.load(open('environment.yaml'));print(d['parameter_defaults']['net2_external_network'].replace('_','-'))" |
     tr '[:upper:]' '[:lower:]')
fi

deploy_portworx_storage=$(python -c "import yaml;d=yaml.load(open('environment.yaml'));print(d['parameter_defaults']['deploy_portworx_storage'])" |
   tr '[:upper:]' '[:lower:]')

function validateSetup() {
  if [[ -z ${OS_TENANT_ID} ]]; then
    echo -e "\nYou must source your OpenStack RC file so we can access the OpenStack API\n"
    exit 1
  fi
}

function getPassword() {
  if [[ -z ${openshift_openstack_password} ]]; then
    echo -e "Please provide a password for the OpenStack tenancy OpenShift will be deployed to..."
    read -s openshift_openstack_password
    echo -e "Starting deployment..."
  fi
}

function setupHeatTemplate() {
  ansible-playbook ./setup-heat-templates.yaml \
    --extra-vars "multinetwork=${multinetwork}" \
    --extra-vars "extra_gateway=${extra_gateway}" \
    --extra-vars "purpose_ident=${purpose_ident}"
}

function addPortworxStorage() {
  ansible-playbook ./add-portworx.yaml \
    --extra-vars "deploy_portworx_storage=${deploy_portworx_storage}" \
    --extra-vars "purpose_ident=${purpose_ident}" \
    --extra-vars "multinetwork=${multinetwork}"
}
function deployHeatStack() {
  openstack stack create -f yaml -t openshift.yaml openshift-${OS_TENANT_NAME} \
    -e rhel_reg_creds.yaml \
    -e environment.yaml \
    --parameter time="$(date)" \
    --parameter os_auth_url="${OS_AUTH_URL}" \
    --parameter os_tenant_id="${OS_TENANT_ID}" \
    --parameter os_tenant_name="${OS_TENANT_NAME}" \
    --parameter os_region="${OS_REGION_NAME}" \
    --parameter openshift_openstack_password="${openshift_openstack_password}" \
    --wait
}

function showBastionIp() {
  openstack stack output show openshift-${OS_TENANT_NAME} --all
}

validateSetup
getPassword
setupHeatTemplate
addPortworxStorage
deployHeatStack
showBastionIp
