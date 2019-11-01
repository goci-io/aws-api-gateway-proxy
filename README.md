# aws-api-gateway-proxy

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

This module creates a proxy integration with API Gateway to route traffic securely into a VPC and proxy an API within that VPC.
The required Network Load Balancer can be placed into multiple subnets by providing the Subnet-ID or a reference to a remote state containing an output `public_subnet_ids`. 

*Note:* The Load Balancer should be placed into the public subnets of your VPC. (TBC with VPCE)

### Usage


### Configuration
