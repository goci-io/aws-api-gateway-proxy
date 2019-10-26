
variable "stage" {
  type        = string
  description = "The stage the resources will be deployed for"
}

variable "name" {
  type        = string
  default     = "api"
  description = "The name for this API"
}

variable "namespace" {
  type        = string
  description = "Organization or company namespace prefix"
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `eu1`)"
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "region" {
  type        = string
  description = "The own region identifier for this deployment"
}

variable "tf_bucket" {
  type        = string
  default     = ""
  description = "The Bucket name to load remote state from"
}

variable "dns_module_state" {
  type        = string
  default     = ""
  description = "The key or path to the state to source hosted zone information from. It must expose a hosted_zone"
}

variable "acm_module_state" {
  type        = string
  default     = ""
  description = "The key or path to the state where a VPC module was installed. It must expose a certificate_arn"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "The ACM Certificate ARN to use if acm_module_state is not set"
}

variable "vpc_module_state" {
  type        = string
  default     = ""
  description = "The key or path to the state where a VPC module was installed. It must expose a vpc_id and private_subnet_ids"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID to use for the target group if vpc_module_state is not set." 
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs to attach the LoadBalancer to"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of API Gateway related AWS resources"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "The domain name to use for the API Gateway"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "The hosted zone name to create the alias record in. Must be set if dns_module_state is empty"
}

variable "health_endpoint" {
  type        = string
  default     = "/healthz"
  description = "Health path to use to check health of the target group"
}

variable "aws_region" {
  type        = string
  description = "The AWS Region to operate in" 
}

variable "aws_assume_role_arn" {
  type        = string
  default     = ""
  description = "The role to assume when creating the API Gateway resources"
}

