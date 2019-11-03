output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "loadbalancer_name" {
  value = aws_lb.nlb.name
}

output "loadbalancer_target_arn" {
  value = aws_lb_target_group.target.arn
}

output "certificate_arn" {
  value = module.letsencrypt.certificate_arn
}

output "certificate_private_key" {
  value     = module.letsencrypt.certificate_key
  sensitive = true
}

output "certificate_body" {
  value = module.letsencrypt.certificate_body
}

output "certificate_ca_cert" {
  value = module.letsencrypt.certificate_ca_cert
}

output "certificate_ca_key" {
  value     = module.letsencrypt.certificate_ca_key
  sensitive = true
}
