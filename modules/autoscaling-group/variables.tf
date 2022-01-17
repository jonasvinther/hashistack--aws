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

variable "vpc_id" {
  description = "The ID of the VPC in which to deploy the cluster"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster_size variable. At least one of var.subnet_ids or var.availability_zones must be non-empty."
  type        = list(string)
  default     = null
}