
resource "aws_api_gateway_domain_name" "domain" {
  domain_name              = local.domain_name
  regional_certificate_arn = local.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "domain" {
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
