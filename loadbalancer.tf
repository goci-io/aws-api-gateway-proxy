
locals {
  name_prefix     = substr(var.name, 0, min(6, length(var.name)))
  health_port     = var.health_port == 0 ? var.target_port : var.health_port
  target_scheme   = var.enable_nlb_https_listener ? "https" : "http"
  target_protocol = var.enable_nlb_https_listener ? "tls" : "tcp"
}

resource "aws_eip" "inbound_ips" {
  count = var.allocate_public_ips ? length(local.subnet_ids) : 0
  tags  = module.label.tags
}

resource "aws_lb" "nlb" {
  name_prefix                      = local.name_prefix
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
  name_prefix = local.name_prefix
  tags        = module.label.tags
  vpc_id      = local.vpc_id
  port        = var.target_port
  protocol    = upper(local.target_protocol)

  health_check {
    enabled  = true
    interval = 10
    protocol = upper(local.target_scheme)
    port     = local.health_port
    matcher  = "200-399"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "https" {
  count             = local.target_protocol == "tls" ? 1 : 0
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

resource "aws_lb_listener" "http" {
  count             = local.target_protocol == "tcp" ? 1 : 0
  load_balancer_arn = aws_lb.nlb.arn
  protocol          = "TCP"
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}
