module "nomad_client" {
  source = "../autoscaling-group"

  cluster_name  = "${var.cluster_name}"
  ami_id = "ami-0d527b8c289b4af7f"
  instance_type = "t2.medium"
  instance_name = "nomad-client"

  min_size         = 2
  max_size         = 3
  desired_capacity = 3

  http_port = 4646

  // # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  // cluster_tag_key   = var.cluster_tag_key
  // cluster_tag_value = var.cluster_tag_value

  // ami_id    = var.ami_id == null ? data.aws_ami.nomad_consul.image_id : var.ami_id
  user_data = data.template_file.user_data_nomad_client.rendered

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  // # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
  // # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  // allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  // ssh_key_name                = var.ssh_key_name

  // tags = [
  //   {
  //     key                 = "Environment"
  //     value               = "development"
  //     propagate_at_launch = true
  //   },
  // ]

  retry_join = {
    tag_key = "NomadAutoJoin"
    tag_value = "auto-join"
  }
}

data "template_file" "user_data_nomad_client" {
  template = file("${path.module}/cloud-init/nomad-client.cfg")
  vars = {
    AWS_ACCESS_KEY_ID = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    NOMAD_DRIVER_RAW_EXEC = "true"
    NOMAD_DRIVER_DOCKER = "true"
    DATACENTER_NAME = "DC1"
  }
}

// Nomad client LB

resource "random_pet" "test" {
  length = 1
}

resource "aws_lb" "test" {
  name               = "${random_pet.test.id}-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.nomad_client.security_group_id]
  subnets            = [for subnet in var.subnet_ids : subnet]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

resource "aws_lb_target_group" "test" {
  name     = "${random_pet.test.id}-asg-test"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_attachment" "test" {
  autoscaling_group_name = module.nomad_client.autoscaling_group_id
  alb_target_group_arn   = aws_lb_target_group.test.arn
}


resource "aws_security_group_rule" "allow_http" {
  count       = length(["0.0.0.0/0"]) > 0 ? 1 : 0
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.nomad_client.security_group_id
}

resource "aws_security_group_rule" "allow_traefik_ui" {
  count       = length(["0.0.0.0/0"]) > 0 ? 1 : 0
  type        = "ingress"
  from_port   = 8081
  to_port     = 8081
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = module.nomad_client.security_group_id
}