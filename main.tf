
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
  apigw_description = var.description == "" ? format("API for %s/%s in %s", var.name, var.stage, var.region) : var.description
}

resource "aws_lb" "nlb" {
  name                             = module.label.id
  tags                             = module.label.tags
  load_balancer_type               = "network"
  internal                         = true
  enable_cross_zone_load_balancing = true

  dynamic "subnet_mapping" {
    for_each = local.subnet_ids

    content {
      subnet_id = subnet_mapping.value
    }
  }
}

resource "aws_api_gateway_vpc_link" "link" {
  name        = module.label.id
  target_arns = [aws_lb.nlb.arn]
  description = format("VPC Link: %s", local.apigw_description)
}

resource "aws_api_gateway_rest_api" "main" {
  name                     = module.label.id
  description              = local.apigw_description
  minimum_compression_size = 572864

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "domain" {
  domain_name              = var.domain_name
  regional_certificate_arn = local.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "request_method" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "vpc" {
  rest_api_id          = aws_api_gateway_rest_api.main.id
  resource_id          = aws_api_gateway_resource.proxy.id
  connection_id        = aws_api_gateway_vpc_link.link.id
  connection_type      = "VPC_LINK"
  type                 = "HTTP_PROXY"
  http_method          = "ANY"
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.stage
}
