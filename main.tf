terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

module "consul-server" {
  source = "./modules/consul"

  cluster_name  = "${var.cluster_name}"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
}

module "nomad" {
  source = "./modules/nomad"

  cluster_name  = "${var.cluster_name}"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLa0W10AALxaTJ8CnYg9rm/qf2qMCezjbcd2YV9+/67 jrvinther@gmail.com"
}

// module "servers" {
//   source = "./modules/autoscaling-group"

//   cluster_name  = "${var.cluster_name}-server"
//   ami_id = "ami-0d527b8c289b4af7f"
//   instance_type = "t2.micro"

//   min_size         = 1
//   max_size         = 1
//   desired_capacity = 1

//   // # The EC2 Instances will use these tags to automatically discover each other and form a cluster
//   // cluster_tag_key   = var.cluster_tag_key
//   // cluster_tag_value = var.cluster_tag_value

//   // ami_id    = var.ami_id == null ? data.aws_ami.nomad_consul.image_id : var.ami_id
//   // user_data = data.template_file.user_data_server.rendered

//   vpc_id     = data.aws_vpc.default.id
//   subnet_ids = data.aws_subnet_ids.default.ids

//   // # To make testing easier, we allow requests from any IP address here but in a production deployment, we strongly
//   // # recommend you limit this to the IP address ranges of known, trusted servers inside your VPC.
//   allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

//   // allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
//   // ssh_key_name                = var.ssh_key_name

//   // tags = [
//   //   {
//   //     key                 = "Environment"
//   //     value               = "development"
//   //     propagate_at_launch = true
//   //   },
//   // ]
// }


# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CLUSTER IN THE DEFAULT VPC AND SUBNETS
# Using the default VPC and subnets makes this example easy to run and test, but it means Consul and Nomad are
# accessible from the public Internet. In a production deployment, we strongly recommend deploying into a custom VPC
# and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = var.vpc_id == "" ? true : false
  id      = var.vpc_id
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_region" "current" {
}