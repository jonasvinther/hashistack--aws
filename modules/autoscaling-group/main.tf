terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.0.0"
}



resource "aws_launch_template" "launch_template" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  key_name = "ssh-key"
  user_data = "${base64encode(var.user_data)}"
  // user_data = "${base64encode(data.template_file.user_data_nomad_server.rendered)}"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.cluster_security_group.id]
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  availability_zones = ["eu-central-1a"]
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}


// data "template_file" "user_data_nomad_server" {
//   template = file("${path.module}/scripts/install-nomad-server.cfg")
//   vars = {
//     NOMAD_SERVER_COUNT = 1,
//     NOMAD_SERVER_JOIN_IP = "",
//     NOMAD_SERVER_ENABLE_CLIENT = "false",
//     NOMAD_DRIVER_RAW_EXEC = "false",
//     DATACENTER_NAME = "DC1"
//   }
// }

// resource "aws_instance" "app_server" {
//   ami           = "ami-0d527b8c289b4af7f"
//   instance_type = "t2.micro"
//   associate_public_ip_address = true
//   key_name = "ssh-key"
//   user_data = data.template_file.user_data_nomad_server.rendered

//   security_groups = [aws_security_group.cluster_security_group.name]

//   tags = {
//     Name = "ExampleAppServerInstance"
//   }
// }

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCcTTa6B//h8YAFW+LQjf0k7q8P2mqGUpokVD5yxIgjCXQhUEeJ5bA0N5zYa4p+HSutMFFnsjzOEWw4FttPdr/hAWo6mcDnq4T5k74dnTYmYsfCcHmXmJt9B2QDZe+AY1OS3W8GyHCVyrfryc/2YXXlK+qV4mX+S6HQKHnp0WjEdr26quhM95JAdsvfW6c8oQxoUvwT2yp5cbo5JEi4t25epYJSgLx9UpUUwG8Zph6tVqCrSH2zFhBgD44yAh1SpdTmG1hQaKneBdkwrxQ7qqToas5u+nPnbCC2COpE8/zd8UMRwAlT4UY2TgaBGpPE2HqcHS3KxYv/RzeCAPU+hoX0KAWwIujAzEG+eifXWLrVavLj89lN/EA/iTN9V2wzvFjO7FvAAXDVwJk6dFSg9Ewo4L2faP+FBGeadpCTUew3VaeWRP3X9OAzKeGaTb6yq3ZWpRC5wD4NIq8wYMudXjFV7sB8eD8mbBGhqOmKX0aNMMInDVeh0qx0SYJTrtXkG+yu9q37/VB/Whojy0IPULJHkXzi4e4yphxP/vLXK1sPg4EE2C1B0shyeohz0d0lCtlyr6BJeKU6QE854OAum82hbnq8mhvXB77zyJhlRVo0U6JLArjAOye7kyouNAqVM+OtkbN7rcO/tuqlxqcs0cmOlPoyEwbIGPkQz/G8ymEQTw== jv@praqma.net"
}

// output "instance_ip" {
//   description = "The public ip for ssh access"
//   value       = aws_instance.app_server.public_ip
// }


// # ---------------------------------------------------------------------------------------------------------------------
// # SECURITY GROUP
// # ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "cluster_security_group" {
  name_prefix = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = var.vpc_id

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  // lifecycle {
  //   create_before_destroy = true
  // }
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  count       = length(var.allowed_ssh_cidr_blocks) > 0 ? 1 : 0
  type        = "ingress"
  from_port   = var.ssh_port
  to_port     = var.ssh_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.http_port
  to_port     = var.http_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}


resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = var.allow_outbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}