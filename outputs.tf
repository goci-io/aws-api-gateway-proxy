output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "loadbalancer_name" {
  value = aws_lb.nlb.name
}
