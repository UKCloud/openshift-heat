The necessary parameters to deploy an external service into a cluster are shown below:

  network_config:
    allocation_pool: [{"start": "10.3.1.2", "end": "10.3.1.100"}]
    cidr: "10.3.1.0/24"
    dns: [ "8.8.4.4" ]
    gateway: "10.3.1.102"
    bastion_ip: "10.3.1.101"
    service_subnet: "10.3.1.240/29" # Subnet to be used for service_ip on services. Must be within internal network range and not conflict with allocation pool.
  external_services_config:
    - service_ip: 10.3.1.240 # Sets the internal IP of the port that a floating IP will be associated to  
      floating_network: "Internet" # Will create a floating IP on the specified network and associate it to the service_ip port.
      # The below options configure the security rule that allows access to your external service.
      proto: tcp or udp 
      port: port to expose e.g. 3306
      allowed_sources: sources allowed to hit service e.g. 0.0.0.0/0
      # The two options below can be used if you want to update a stack but only add a port/IP or rule without the other
      sec_rule_deploy: false
      port_ip_deploy: false

The best way to update a stack and add/remove external services is to write an environment file containing only the parameters you want and pass it into the stack update in the following way:

openstack stack update <stack> --existing -e service-update.yaml

The network of a floating IP can be overwritten in an update allowing you to change networks that services are exposed on easily however you cannot update the port the floating IP is attached to without first removing both resources. Ensure to keep external_services_config blocks in the same order when updating. As these iterate over a resourcegroup if you change the order to the resources will be removed and recreated meaning your floating IP will change.
