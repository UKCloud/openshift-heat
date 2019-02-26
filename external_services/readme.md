### Exposing External Services

This readme intends to give you the information required to run stack updates that deploy the necessary infrastructure to allow non-http services to be exposed outside our clusters. The following parameter addition is required to deploy even if you are not exposing any services:

```
 network_config:
    allocation_pool: [{"start": "10.3.1.2", "end": "10.3.1.100"}]
    cidr: "10.3.1.0/24"
    dns: [ "8.8.4.4" ]
    gateway: "10.3.1.102"
    bastion_ip: "10.3.1.101"
    service_subnet: "10.3.1.240/29" # This is the new addition. It's the subnet to be used for service_ip on services. Must be within internal network range and not conflict with allocation pool.
```

The parameter used to deploy the actual external_services infrastructure is external_services_config, this can be hashed out if not required and it will not try to create the external services resource at the top level. If you do want to use an external service then the following block is an example:

```
 external_services_config:
    - service_ip: 10.3.1.240 # Sets the internal IP of the port that a floating IP will be associated to  
      floating_network: "Internet" # Will create a floating IP on the specified network and associate it to the service_ip port.
      proto: tcp or udp # Used in the security rule thats created to allow access. Should match the service protocol.
      port: 3306 # Used in the security rule thats created to allow access. Should match the service port.
      allowed_sources: sources allowed to hit service e.g. 0.0.0.0/0 # Used in the security rule thats created to allow access
```

It's important to note that the blocks are a list of json objects. The order of them matters, if you are updating a cluster to add extra services you MUST keep them in the correct order otherwise the already exposed services will be destroyed. An example of deploying two external services would be:

```
 external_services_config:
    - service_ip: 10.3.1.240 
      floating_network: "Internet"
      proto: tcp
      port: 3306
      allowed_sources: 0.0.0.0/0
    - service_ip: 10.3.1.241
      floating_network: "Internet"
      proto: tcp
      port: 3307
      allowed_sources: 0.0.0.0/0
```

The above will deploy two floating IPs on the internet, one mapped to the internal IP of 10.3.1.240 and the other mapped to the internal IP of 10.3.1.241. It will also add two security rules to all nodes allowing access to 3307 and 3306 from all sources. While this may seem insecure IPtables rules within the cluster will ensure you can only hit the relevant service on the relevant IP once they have been exposed.

What if a customer wants to expose multiple services on a single IP? Well let's say the customer wants one internet IP and would like to expose tcp 3306 and udp 53 on it. The way this would be done is:

```
 external_services_config:
    - service_ip: 10.3.1.240 
      floating_network: "Internet"
      proto: tcp
      port: 3306
      allowed_sources: 0.0.0.0/0
    - port_ip_deploy: false
      proto: udp
      port: 53
      allowed_sources: 0.0.0.0/0
```

In the above port_ip_deploy: false specifies to not create a floating IP or internal IP so the second block is only creating a security rule allowing access to the nodes on port 53 from all sources. You could then expose two services on 10.3.1.240 from inside the cluster and each would be reachable on the same floating IP.

To remove a resource you would simply change the block it exists in to the following:

```
 external_services_config:
    - port_ip_deploy: false
      sec_rule_deploy: false
    - port_ip_deploy: false
      proto: udp
      port: 53
      allowed_sources: 0.0.0.0/0
```

In the above the first block used to create an internal IP of 10.3.1.240, map a floating IP from the internet to it and create a security rule allowing access on 3306. port_ip_deploy: false and sec_rule_deploy: false will ensure that when you update the stack this resource block will be evaluated and all resources previously related to it will be destroyed.

If you wanted to change a floating IP to a different network you cannot simply overwrite the floating_network parameter and update. You first need to destroy the resources from the block in an update and then specify a new network and update. The stages would be:

```
 external_services_config:
    - service_ip: 10.3.1.240 
      floating_network: "Internet"
      proto: tcp
      port: 3306
      allowed_sources: 0.0.0.0/0
```

Original deployment config. Customer then asks for the 10.3.1.240 to be accessible on HSCN rather than the internet:

```
 external_services_config:
    - port_ip_deploy: false
      sec_rule_deploy: false
```

Update is run, destroying the resources.

```
 external_services_config:
    - service_ip: 10.3.1.240 
      floating_network: "HSCN"
      proto: tcp
      port: 3306
      allowed_sources: 0.0.0.0/0
```

Final update is run re-creating the resources.

Finally, the best way to go about updating these parameters is to create your own yaml file containing the block (in this example it's service-update.yml) and running the following:

```
openstack stack update <stack> --existing -e service-update.yml
```
