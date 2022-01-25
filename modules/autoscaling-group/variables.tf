# ---------------------------------------------------------------------------------------------------------------------
# Required parameters
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the Nomad cluster."
  type        = string
}

variable "ami_id" {
  description = "The ID of the AMI to run in this autoscaling group."
  type        = string
}

variable "instance_name" {
  description = "The name of the auto scaling group instance."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run for each node in the autoscaling group (e.g. t2.micro)."
  type        = string
}

variable "min_size" {
  description = "The minimum number of nodes to have in the autoscaling group. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

variable "max_size" {
  description = "The maximum number of nodes to have in the autoscaling group. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

variable "desired_capacity" {
  description = "The desired number of nodes to have in the autoscaling group. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5."
  type        = number
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional parameters
# ---------------------------------------------------------------------------------------------------------------------

variable "retry_join" {
  type = map(string)

  default = {
    provider  = "aws"
    tag_key   = "AutoJoin"
    tag_value = "no-join"
  }
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections"
  type        = list(string)
  default     = []
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allow_outbound_cidr_blocks" {
  description = "Allow outbound traffic to these CIDR blocks."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_port" {
  description = "The port used for SSH connections"
  type        = number
  default     = 22
}

variable "http_port" {
  description = "The port to use for HTTP"
  type        = number
  default     = 4646
}

variable "rpc_port" {
  description = "The port to use for RPC"
  type        = number
  default     = 4647
}

variable "serf_port" {
  description = "The port to use for Serf"
  type        = number
  default     = 4648
}

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the cluster"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = list(string)
  default     = null
}


# Consul
variable "allowed_inbound_security_group_ids" {
  description = "A list of security group IDs that will be allowed to connect to Consul"
  type        = list(string)
  default     = []
}

variable "allowed_inbound_security_group_count" {
  description = "The number of entries in var.allowed_inbound_security_group_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only."
  type        = number
  default     = 0
}

variable "server_rpc_port" {
  description = "The port used by servers to handle incoming requests from other agents."
  type        = number
  default     = 8300
}

variable "cli_rpc_port" {
  description = "The port used by all agents to handle RPC from the CLI."
  type        = number
  default     = 8400
}

variable "serf_lan_port" {
  description = "The port used to handle gossip in the LAN. Required by all agents."
  type        = number
  default     = 8301
}

variable "serf_wan_port" {
  description = "The port used by servers to gossip over the WAN to other servers."
  type        = number
  default     = 8302
}

variable "http_api_port" {
  description = "The port used by clients to talk to the HTTP API"
  type        = number
  default     = 8500
}

variable "https_api_port" {
  description = "The port used by clients to talk to the HTTPS API. Only used if enable_https_port is set to true."
  type        = number
  default     = 8501
}

variable "dns_port" {
  description = "The port used to resolve DNS queries."
  type        = number
  default     = 8600
}

variable "enable_https_port" {
  description = "If set to true, allow access to the Consul HTTPS port defined via the https_api_port variable."
  type        = bool
  default     = false
}