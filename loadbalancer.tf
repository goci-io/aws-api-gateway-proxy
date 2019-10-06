
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
  name                 = module.label.id
  tags                 = module.label.tags
  port                 = 80
  protocol             = "TCP"
  vpc_id               = local.vpc_id
  deregistration_delay = 120

  health_check {
    healthy_threshold   = 2
    interval            = 30
    path                = var.health_endpoint
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "forward" {
  load_balancer_arn = aws_lb.nlb.arn
  certificate_arn   = local.certificate_arn
  protocol          = "TCP"
  port              = 443

  default_action {
    target_group_arn = aws_lb_target_group.target.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "https_redirect" {
  load_balancer_arn = aws_lb.nlb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}