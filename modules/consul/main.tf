terraform {
  required_version = ">= 1.0.0"
}

module "consul_server" {
  source = "../autoscaling-group"

  cluster_name  = "${var.cluster_name}"
  ami_id = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  http_port = 8500

  // # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  // cluster_tag_key   = var.cluster_tag_key
  // cluster_tag_value = var.cluster_tag_value

  // ami_id    = var.ami_id == null ? data.aws_ami.nomad_consul.image_id : var.ami_id
  user_data = data.template_file.user_data_consul_server.rendered

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
}

data "template_file" "user_data_consul_server" {
  template = file("${path.module}/cloud-init/consul-server.cfg")
  vars = {
    NOMAD_SERVER_COUNT = 1,
    NOMAD_SERVER_JOIN_IP = "",
    NOMAD_SERVER_ENABLE_CLIENT = "false",
    NOMAD_DRIVER_RAW_EXEC = "false",
    DATACENTER_NAME = "DC1"
    NODE_IP = ""
  }
}