output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = try(aws_autoscaling_group.autoscaling_group.id)
}

output "security_group_id" {
  description = "The security group id"
  value       = try(aws_security_group.cluster_security_group.id)
}
