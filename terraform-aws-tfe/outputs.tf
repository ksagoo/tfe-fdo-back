#------------------------------------------------------------------------------
# TFE
#------------------------------------------------------------------------------
output "tfe_url" {
  value       = "https://${var.tfe_hostname}"
  description = "URL of TFE application based on `tfe_hostname` input."
}

output "tfe_admin_console_url" {
  value       = "https://${var.tfe_hostname}:8800"
  description = "URL of TFE (Replicated) Admin Console based on `tfe_hostname` input."
}

output "user_data_script" {
  value       = base64decode(aws_launch_template.lt.user_data)
  description = "base64 decoded user data script that is attached to the launch template"
  sensitive   = true
}

output "launch_template_name" {
  value       = aws_launch_template.lt.name
  description = "Name of the AWS launch template that was created during the run"
}

output "asg_name" {
  value       = aws_autoscaling_group.asg.name
  description = "Name of the AWS autoscaling group that was created during the run."
}

output "asg_healthcheck_type" {
  value       = aws_autoscaling_group.asg.health_check_type
  description = "Type of health check that is associated with the AWS autoscaling group."
}

output "asg_target_group_arns" {
  value       = aws_autoscaling_group.asg.target_group_arns
  description = "List of the target group ARNs that are used for the AWS autoscaling group"
}

output "security_group_ids" {
  value       = [aws_security_group.ec2_sg.id]
  description = "List of security groups that have been created during the run."
}



