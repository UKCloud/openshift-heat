# Overview

OpenStack Heat template used to deploy basic OpenShift cluster.

Initial build deploys bastion host with DNS server built in, worker nodes and master nodes according to specified scale.

# Setup environment details
Edit environment.yaml with the details for the deployment

Edit rhel_reg_creds.yaml with the  Red Hat registration details used to access the Red Hat repos

The Openshift floating IP can either be pre-configured or dynamically assigned.

To pre-configure reserve a floating IP in OpenStack by running:

```
openstack floating ip create <External Network ID>
```

Add the ID returned to the key haproxy_floating_ip in environment.yaml.

If you wish to have it dynamically assigned then comment out the key haproxy_floating_ip in the environment.yaml

# Deploy Stack
Create stack with:
```
./deploy.sh
```
