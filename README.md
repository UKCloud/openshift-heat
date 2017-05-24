# Overview

OpenStack Heat template used to deploy basic OpenShift cluster.

Initial build deploys bastion host with DNS server built in, worker nodes and master nodes according to specified scale.

Create stack with:
```
openstack stack create -f yaml -t openshift.yaml openshift_testing -e rhel_reg_creds.yaml
```
Note: rhel_reg_creds.yaml specifies RHEL registration credentials for use in the openshift.yml file.
