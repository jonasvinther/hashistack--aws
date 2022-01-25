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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcTTa6B//h8YAFW+LQjf0k7q8P2mqGUpokVD5yxIgjCXQhUEeJ5bA0N5zYa4p+HSutMFFnsjzOEWw4FttPdr/hAWo6mcDnq4T5k74dnTYmYsfCcHmXmJt9B2QDZe+AY1OS3W8GyHCVyrfryc/2YXXlK+qV4mX+S6HQKHnp0WjEdr26quhM95JAdsvfW6c8oQxoUvwT2yp5cbo5JEi4t25epYJSgLx9UpUUwG8Zph6tVqCrSH2zFhBgD44yAh1SpdTmG1hQaKneBdkwrxQ7qqToas5u+nPnbCC2COpE8/zd8UMRwAlT4UY2TgaBGpPE2HqcHS3KxYv/RzeCAPU+hoX0KAWwIujAzEG+eifXWLrVavLj89lN/EA/iTN9V2wzvFjO7FvAAXDVwJk6dFSg9Ewo4L2faP+FBGeadpCTUew3VaeWRP3X9OAzKeGaTb6yq3ZWpRC5wD4NIq8wYMudXjFV7sB8eD8mbBGhqOmKX0aNMMInDVeh0qx0SYJTrtXkG+yu9q37/VB/Whojy0IPULJHkXzi4e4yphxP/vLXK1sPg4EE2C1B0shyeohz0d0lCtlyr6BJeKU6QE854OAum82hbnq8mhvXB77zyJhlRVo0U6JLArjAOye7kyouNAqVM+OtkbN7rcO/tuqlxqcs0cmOlPoyEwbIGPkQz/G8ymEQTw== jv@praqma.net"
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