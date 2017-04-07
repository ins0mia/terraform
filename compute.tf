// - Security groups
resource "aws_security_group" "web" {
    name = "${var.project_name}-web"
    description = "Allow traffic to ec2 instances"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.allowed_ip_to_access_rds}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "WEB"
    }
}

resource "aws_security_group" "alb" {
    name = "${var.project_name}-load_balancer"
    description = "Allow traffic to alb"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = ["${aws_security_group.web.id}"]
    }
    egress {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = ["${aws_security_group.web.id}"]
    }
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "WEB-ALB"
    }
}

// - Computing

resource "aws_alb" "web" {
  name            = "${var.project_name}-web-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${aws_subnet.us-west-2-ec2.*.id}"]

  enable_deletion_protection = false

  tags {
    environment = "prod"
  }
}

resource "aws_alb_target_group" "web" {
  name     = "web-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    interval = "60"
    path = "/"
    port = 80
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = 200
  }
}

resource "aws_alb_listener" "web" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "web" {
  name   = "${var.project_name}-web_configuration"
  image_id      = "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.web.id}"]
  key_name = "${var.aws_key_name}"
  enable_monitoring = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name_prefix = "web-site-"
  max_size                  = 5
  min_size                  = 1
  default_cooldown          = 60
  health_check_grace_period = 600
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = ["${aws_subnet.us-west-2-ec2.*.id}"]
  launch_configuration      = "${aws_launch_configuration.web.name}"
  target_group_arns         = ["${aws_alb_target_group.web.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "environment"
    value               = "prod"
    propagate_at_launch = true
  }

  tag {
    key                 = "service"
    value               = "web"
    propagate_at_launch = true
  }
}
