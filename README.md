# Overview

OpenStack Heat template used to deploy basic OpenShift cluster.

Initial build deploys bastion host, loadbalancers for control plane and data plane, and master, infra and worker nodes as per scale in environment.yml

# Setup environment details
Copy the 2 example yaml files as follows:
```
cp environment_example.yaml environment.yaml
cp rhel_reg_creds_example.yaml rhel_reg_creds.yaml
```

Edit environment.yaml with the details for the deployment.

Edit rhel_reg_creds.yaml with the Red Hat registration details used to access the Red Hat repositories or Satellite server if required.

## Floating IP address
The external IP addresses required for the control plane and data plane are needed in advance, they can be allocated in OpenStack as follows:

```
openstack floating ip create <External Network ID>
```

and add the ID returned to the keys 'controlplane_floating_ip' and 'dataplane_floating_ip' in environment.yaml.

Finally if a only a single network is required ensure multinetwork is set to false and deploy as follows: 

# Deploy Stack
Create stack with:
```
./deploy.sh false
```

If you require 2 different external networks and data planes on both, you need to set the require net2 variables in the environment.yaml (in particular the net2_node_routes will be needed if the secondary network is not able to connect to the container registry you're deploying from) then deploy with multinetwork set to true, as follows:

# Deploy Stack
Create stack with:
```
./deploy.sh true
```
