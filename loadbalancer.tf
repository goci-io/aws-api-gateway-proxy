
resource "aws_eip" "inbound_ips" {
  count = var.allocate_public_ips ? length(local.subnet_ids) : 0
  tags  = module.label.tags
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
      subnet_id     = subnet_mapping.value
      allocation_id = var.allocate_public_ips ? element(aws_eip.inbound_ips.*.id, subnet_mapping.key) : ""
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "target" {
  name     = module.label.id
  tags     = module.label.tags
  vpc_id   = local.vpc_id
  protocol = "TCP"
  port     = 80

  health_check {
    enabled  = true
    interval = 10
    protocol = "HTTP"
    port     = var.health_port
    path     = var.health_endpoint
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = aws_lb.nlb.arn
  certificate_arn   = local.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  protocol          = "TLS"
  port              = 443

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}
