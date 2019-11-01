output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "loadbalancer_name" {
  value = aws_lb.nlb.name
}

output "loadbalancer_target_arn" {
  value = aws_lb_target_group.target.arn
}

output "acme_certificate_arn" {
  value = module.letsencrypt.certificate_arn
}

output "acm_private_key" {
  value     = module.letsencrypt.certificate_key
  sensitive = true
}

output "acme_certificate_body" {
  value = module.letsencrypt.certificate_body
}

output "acme_certificate_chain" {
  value = module.letsencrypt.certificate_chain
}
