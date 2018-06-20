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

Whether to deploy with multiple networks (e.g. an extra external network and a data plane on it), and whether to deploy with just an extra external network router (access to which can be controlled by passing in static routes to the appropriate nodes) can be controlled through the ```multinetwork``` and ```deploy_extra_gateway``` parameters.

Finally if a only a single network is required ensure multinetwork is set to false and deploy as follows: 

# Deploy Stack
Create stack with:
```
./deploy.sh
```
