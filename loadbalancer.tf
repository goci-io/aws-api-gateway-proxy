
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

resource "aws_lb_target_group" "target" {
  name_prefix = module.label.id
  tags        = module.label.tags
  port        = 443
  protocol    = "TLS"
  vpc_id      = local.vpc_id

  health_check {
    enabled  = true
    interval = 30
    protocol = "TCP"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = aws_lb.nlb.arn
  certificate_arn   = local.certificate_arn
  protocol          = "TLS"
  port              = 443

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}
