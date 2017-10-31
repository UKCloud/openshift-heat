# Overview

OpenStack Heat template used to deploy basic OpenShift cluster.

Initial build deploys bastion host with DNS server built in, worker nodes and master nodes according to specified scale.

# Setup environment details
Copy the 2 example yaml files as follows:
```
cp environment_example.yaml environment.yaml
cp rhel_reg_creds_example.yaml rhel_reg_creds.yaml
```

Edit environment.yaml with the details for the deployment.

Edit rhel_reg_creds.yaml with the Red Hat registration details used to access the Red Hat repositories.

## Floating IP address
The Openshift floating IP can either be pre-configured or dynamically assigned.

To use a pre-configured IP address,  reserve a floating IP in OpenStack by running:

```
openstack floating ip create <External Network ID>
```

and add the ID returned to the key 'haproxy_floating_ip' in environment.yaml.

To use a dynamically assigned IP address, ensure the line starting "haproxy_floating_ip" in environment.yaml
is commented out.

# Deploy Stack
Create stack with:
```
./deploy.sh
```
