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

  tag {
    key                 = var.retry_join.tag_key
    value               = var.retry_join.tag_value
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
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

resource "aws_security_group_rule" "allow_rpc_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.rpc_port
  to_port     = var.rpc_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_tcp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.serf_port
  to_port     = var.serf_port
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




# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP RULES THAT CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF A CONSUL CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_server_rpc_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.server_rpc_port
  to_port     = var.server_rpc_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_cli_rpc_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.cli_rpc_port
  to_port     = var.cli_rpc_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_tcp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.serf_wan_port
  to_port     = var.serf_wan_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_udp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.serf_wan_port
  to_port     = var.serf_wan_port
  protocol    = "udp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

// resource "aws_security_group_rule" "allow_http_api_inbound" {
//   count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
//   type        = "ingress"
//   from_port   = var.http_api_port
//   to_port     = var.http_api_port
//   protocol    = "tcp"
//   cidr_blocks = var.allowed_inbound_cidr_blocks

//   security_group_id = aws_security_group.cluster_security_group.id
// }

resource "aws_security_group_rule" "allow_https_api_inbound" {
  count       = var.enable_https_port && length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.https_api_port
  to_port     = var.https_api_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_tcp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.dns_port
  to_port     = var.dns_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_udp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.dns_port
  to_port     = var.dns_port
  protocol    = "udp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_server_rpc_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.server_rpc_port
  to_port                  = var.server_rpc_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_cli_rpc_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.cli_rpc_port
  to_port                  = var.cli_rpc_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_tcp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.serf_wan_port
  to_port                  = var.serf_wan_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_udp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.serf_wan_port
  to_port                  = var.serf_wan_port
  protocol                 = "udp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_http_api_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.http_api_port
  to_port                  = var.http_api_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_https_api_inbound_from_security_group_ids" {
  count                    = var.enable_https_port ? var.allowed_inbound_security_group_count : 0
  type                     = "ingress"
  from_port                = var.https_api_port
  to_port                  = var.https_api_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_tcp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.dns_port
  to_port                  = var.dns_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_udp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.dns_port
  to_port                  = var.dns_port
  protocol                 = "udp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

# Similar to the *_inbound_from_security_group_ids rules, allow inbound from ourself

resource "aws_security_group_rule" "allow_server_rpc_inbound_from_self" {
  type      = "ingress"
  from_port = var.server_rpc_port
  to_port   = var.server_rpc_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_cli_rpc_inbound_from_self" {
  type      = "ingress"
  from_port = var.cli_rpc_port
  to_port   = var.cli_rpc_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_tcp_inbound_from_self" {
  type      = "ingress"
  from_port = var.serf_wan_port
  to_port   = var.serf_wan_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_wan_udp_inbound_from_self" {
  type      = "ingress"
  from_port = var.serf_wan_port
  to_port   = var.serf_wan_port
  protocol  = "udp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_http_api_inbound_from_self" {
  type      = "ingress"
  from_port = var.http_api_port
  to_port   = var.http_api_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_https_api_inbound_from_self" {
  count     = var.enable_https_port ? 1 : 0
  type      = "ingress"
  from_port = var.https_api_port
  to_port   = var.https_api_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_tcp_inbound_from_self" {
  type      = "ingress"
  from_port = var.dns_port
  to_port   = var.dns_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_dns_udp_inbound_from_self" {
  type      = "ingress"
  from_port = var.dns_port
  to_port   = var.dns_port
  protocol  = "udp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}






## ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP RULES THAT CONTROL WHAT TRAFFIC CAN GO IN AND OUT OF A CONSUL AGENT CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_serf_lan_tcp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.serf_lan_port
  to_port     = var.serf_lan_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_lan_udp_inbound" {
  count       = length(var.allowed_inbound_cidr_blocks) >= 1 ? 1 : 0
  type        = "ingress"
  from_port   = var.serf_lan_port
  to_port     = var.serf_lan_port
  protocol    = "udp"
  cidr_blocks = var.allowed_inbound_cidr_blocks

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_lan_tcp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.serf_lan_port
  to_port                  = var.serf_lan_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_lan_udp_inbound_from_security_group_ids" {
  count                    = var.allowed_inbound_security_group_count
  type                     = "ingress"
  from_port                = var.serf_lan_port
  to_port                  = var.serf_lan_port
  protocol                 = "udp"
  source_security_group_id = element(var.allowed_inbound_security_group_ids, count.index)

  security_group_id = aws_security_group.cluster_security_group.id
}

# Similar to the *_inbound_from_security_group_ids rules, allow inbound from ourself

resource "aws_security_group_rule" "allow_serf_lan_tcp_inbound_from_self" {
  type      = "ingress"
  from_port = var.serf_lan_port
  to_port   = var.serf_lan_port
  protocol  = "tcp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}

resource "aws_security_group_rule" "allow_serf_lan_udp_inbound_from_self" {
  type      = "ingress"
  from_port = var.serf_lan_port
  to_port   = var.serf_lan_port
  protocol  = "udp"
  self      = true

  security_group_id = aws_security_group.cluster_security_group.id
}