# aws-api-gateway

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

This module creates a proxy integration with API Gateway to route traffic securely into a VPC and proxy an API within that VPC.
The required Network Load Balancer can be placed into multiple subnets by providing the Subnet-ID or a reference to a remote state containing an output `private_subnet_ids`. 
