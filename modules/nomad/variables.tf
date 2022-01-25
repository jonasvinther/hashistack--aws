variable "cluster_name" {
  description = "What to name the cluster and all of its associated resources"
  type        = string
  default     = "nomad-example"
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

variable "retry_join" {
  type = map(string)

  default = {
    provider  = "aws"
    tag_key   = ""
    tag_value = ""
  }
}

variable "aws_access_key_id" {
  description = "AWS access key id."
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key."
  type        = string
  default     = ""
}