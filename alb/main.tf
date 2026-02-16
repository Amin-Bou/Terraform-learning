resource "aws_lb" "main" {
    name        = "cb-load-balancer"
    subnets         = [var.public_subnet_1_id,
                      var.public_subnet_2_id]
    security_groups = [aws_security_group.lb_sg.id]
}

#Target group

resource "aws_lb_target_group" "app" {
    name        = "cb-target-group"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "instance"
}



# Listener: Traffic from LB -> TG
resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    # target_group_arn = aws_lb_target_group.app.id
    type             = "redirect"
     
     redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  
}


resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}


#SG

resource "aws_security_group" "lb_sg" {
  name        = "HTTPS"
  description = "allow HTTPS traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = "sg_lb_https"
  }
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_https" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "lb_sg_http" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
#   security_group_id = aws_security_group.lb_sg.id
#   cidr_ipv6         = "::/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }

# #Listener cert
# resource "aws_lb_listener_certificate" "https_cert" {
#   listener_arn    = aws_lb_listener.front_end.arn
#   certificate_arn = var.cert_arn
# }

#Target group attachment

resource "aws_lb_target_group_attachment" "ec2_public" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.public_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_public_2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.public_instance_2_id
  port             = 80
}