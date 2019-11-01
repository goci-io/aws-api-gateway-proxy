
module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  delimiter  = var.delimiter
  name       = var.name
  attributes = var.attributes
  tags       = merge(var.tags, { Region = var.region })
}

locals {
  domain_name       = var.domain_name == "" ? format("%s.%s", var.name, local.hosted_zone) : var.domain_name
  apigw_description = var.description == "" ? format("API for %s/%s in %s", var.name, var.stage, var.region) : var.description
}

resource "aws_api_gateway_rest_api" "main" {
  name                     = module.label.id
  description              = local.apigw_description
  minimum_compression_size = 572864

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method_settings" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "ERROR"
  }
}

resource "aws_api_gateway_integration" "vpc" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.proxy.id
  connection_id           = aws_api_gateway_vpc_link.link.id
  uri                     = format("%s://%s/{proxy}", local.target_scheme, local.domain_name)
  request_parameters      = { "integration.request.path.proxy" = "method.request.path.proxy" }
  cache_key_parameters    = ["method.request.path.proxy"]
  integration_http_method = "ANY"
  http_method             = "ANY"
  connection_type         = "VPC_LINK"
  type                    = "HTTP_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_cloudwatch_log_group" "stage_logs" {
  name              = format("API-Gateway-Execution-Logs_%s/%s", aws_api_gateway_rest_api.main.id, var.stage)
  tags              = module.label.tags
  retention_in_days = 14
}

resource "aws_api_gateway_stage" "stage" {
  stage_name    = var.stage
  tags          = module.label.tags
  description   = local.apigw_description
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.vpc]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.stage
}
