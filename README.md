# Overview

OpenStack Heat template used to deploy basic OpenShift cluster.

Initial build deploys bastion host with DNS server built in, worker nodes and master nodes according to specified scale.

Create stack with:
```
openstack stack create -f yaml -t openshift.yaml openshift_testing -e rhel_reg_creds.yaml --parameter time="$(date)" --parameter os_auth_url=$OS_AUTH_URL --parameter os_tenant_id=$OS_TENANT_ID --parameter os_tenant_name=$OS_TENANT_NAME --parameter os_region=$OS_REGION_NAME --parameter domain_suffix=example.com --parameter openshift_openstack_username=xxxx openshift_openstack_password=xxxx
```
Note: rhel_reg_creds.yaml specifies RHEL registration credentials for use in the openshift.yml file.
