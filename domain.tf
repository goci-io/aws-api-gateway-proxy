
module "letsencrypt" {
  source              = "git::https://github.com/goci-io/aws-acm-letsencrypt.git?ref=master"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.name
  region              = var.region
  domain_name         = local.domain_name
  aws_region          = var.aws_region
  aws_assume_role_arn = var.aws_assume_role_arn
  certificate_email   = var.letsencrypt_certificate_email
  enabled             = var.use_letsencrypt_certificate
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name              = local.domain_name
  regional_certificate_arn = local.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "domain" {
  depends_on  = [aws_api_gateway_stage.stage]
  api_id      = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  domain_name = aws_api_gateway_domain_name.domain.domain_name
}

module "apigw_record" {
  source      = "git::https://github.com/goci-io/aws-route53-records.git?ref=tags/0.2.0"
  hosted_zone = local.hosted_zone
  alias_records = [
    {
      name       = var.name
      alias      = aws_api_gateway_domain_name.domain.regional_domain_name
      alias_zone = aws_api_gateway_domain_name.domain.regional_zone_id
    }
  ]
}

/*
data "aws_vpc_endpoint" "endpoint" {
  count        = var.enable_vpce_dns_sync ? 1 : 0
  depends_on   = [aws_api_gateway_integration.vpc]
  vpc_id       = local.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.execute-api"
}

module "private_apigw_record" {
  source          = "git::https://github.com/goci-io/aws-route53-records.git?ref=master"
  hosted_zone     = local.private_hosted_zone
  enabled         = var.enable_vpce_dns_sync
  is_private_zone = true
  alias_records   = [
    {
      name       = var.name
      alias      = join("", data.aws_vpc_endpoint.endpoint.*.dns_entry.dns_name)
      alias_zone = join("", data.aws_vpc_endpoint.endpoint.*.dns_entry.hosted_zone_id)
    }
  ]
}
*/
