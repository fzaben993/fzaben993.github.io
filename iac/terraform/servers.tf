
# Resource definitions
resource "aws_security_group" "lb_security_group" {
  name        = "${var.environment_name}-LBSecGroup"
  description = "Allow http to our load balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_server_security_group" {
  name        = "${var.environment_name}-WebServerSecGroup"
  description = "Allow http to our hosts and SSH from local only"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "web_app_launch_config" {
  name_prefix          = "${var.environment_name}-WebAppLaunchConfig"
  image_id             = var.AmazonLinuxAMI
  key_name             = var.KeyPairName
  security_groups      = [aws_security_group.web_server_security_group.id]
  instance_type        = var.InstanceType
  
  user_data            = "${file("web_app_user_data.sh")}"

  ebs_block_device {
    device_name = "/dev/sdk"
    volume_size = 10
    volume_type = "gp3"
  }
}

resource "aws_lb_target_group" "web_app_target_group" {
  name                   = "${var.environment_name}-WebAppTargetGroup"
  port                   = 80
  protocol               = "HTTP"
  vpc_id                 = aws_vpc.vpc.id

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 8
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_autoscaling_group" "web_app_group" {
  name                      = "${var.environment_name}-WebAppGroup"
  launch_configuration      = aws_launch_configuration.web_app_launch_config.name
  min_size                  = 2
  max_size                  = 5
  vpc_zone_identifier       = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  
  target_group_arns         = [aws_lb_target_group.web_app_target_group.arn]
  depends_on = [aws_lb_target_group.web_app_target_group]
}

resource "aws_lb" "web_app_lb" {
  name               = "${var.environment_name}-WebAppLB"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups    = [aws_security_group.lb_security_group.id]
  depends_on = [aws_security_group.lb_security_group]

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}

resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
  depends_on = [aws_lb_listener.listener]

}


