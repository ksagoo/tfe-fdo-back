#------------------------------------------------------------------------------
# TFE
#------------------------------------------------------------------------------

output "tfe_url" {
  value       = module.tfe.tfe_url
  description = "URL of TFE application based on `route53_failover_fqdn` input."
}

output "tfe_admin_console_url" {
  value       = module.tfe.tfe_admin_console_url
  description = "URL of TFE (Replicated) Admin Console based on `route53_failover_fqdn` input."
}

output "user_data_script" {
  value       = module.tfe.user_data_script
  description = "base64 decoded user data script that is attached to the launch template"
  sensitive   = true
}

output "launch_template_name" {
  value       = module.tfe.launch_template_name
  description = "Name of the AWS launch template that was created during the run"
}

output "asg_name" {
  value       = module.tfe.asg_name
  description = "Name of the AWS autoscaling group that was created during the run."
}

output "asg_healthcheck_type" {
  value       = module.tfe.asg_healthcheck_type
  description = "Type of health check that is associated with the AWS autoscaling group."
}

output "asg_target_group_arns" {
  value       = module.tfe.asg_target_group_arns
  description = "List of the target group ARNs that are used for the AWS autoscaling group"
}

output "security_group_ids" {
  value       = module.tfe.security_group_ids
  description = "List of security groups that have been created during the run."
}