locals {
  certificate_arn   = var.acm_module_state == "" ? var.certificate_arn : data.terraform_remote_state.acm[0].outputs.certificate_arn
  subnet_ids        = var.vpc_module_state == "" ? var.subnet_ids : concat(var.subnet_ids, data.terraform_remote_state.vpc[0].outputs.private_subnet_ids)
}

data "terraform_remote_state" "vpc" {
  count   = var.vpc_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.vpc_module_state
  }
}

data "terraform_remote_state" "acm" {
  count   = var.acm_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.acm_module_state
  }
}
