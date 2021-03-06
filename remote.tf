locals {
  custom_cert     = var.use_letsencrypt_certificate ? module.letsencrypt.certificate_arn : var.certificate_arn
  hosted_zone     = var.dns_module_state == "" ? var.domain_name : data.terraform_remote_state.dns[0].outputs.domain_name
  certificate_arn = var.acm_module_state == "" ? local.custom_cert : data.terraform_remote_state.acm[0].outputs.certificate_arn
  vpc_id          = var.vpc_module_state == "" ? var.vpc_id : data.terraform_remote_state.vpc[0].outputs.vpc_id
  subnet_ids      = var.vpc_module_state == "" ? var.subnet_ids : concat(var.subnet_ids, data.terraform_remote_state.vpc[0].outputs.public_subnet_ids)
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

data "terraform_remote_state" "dns" {
  count   = var.dns_module_state == "" ? 0 : 1
  backend = "s3"

  config = {
    bucket = var.tf_bucket
    key    = var.dns_module_state
  }
}
