data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_alb" "alb" {
  name             = "terraform-example-alb"
  security_groups  = var.security_groups
  subnets          = data.aws_subnet_ids.all.ids
}

resource "aws_alb_target_group" "group" {
  name     = "terraform-example-alb-target"
  port     = 33333
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/listallcustomers"
    port = 33333
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.group.arn
    type             = "forward"
  }
}

resource "aws_launch_configuration" "as_conf" {
    name_prefix = "as_conf-"
    image_id = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    lifecycle {
        create_before_destroy = true
    }

    root_block_device {
        volume_type = "gp2"
        volume_size = "8"
    }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "terraform-asg"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 2
  max_size             = 3
  availability_zones = ["us-east-2a","us-east-2b"]
  desired_capacity = 2
  force_delete = true
  health_check_grace_period = 300
  health_check_type = "EC2"
  target_group_arns = [aws_alb_target_group.group.arn]

  lifecycle {
    create_before_destroy = true
  }

  tag {
        key = "Name"
        value = "ASG Instance"
        propagate_at_launch = true
    }
}
