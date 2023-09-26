output "redis_primary_endpoint" {
  value       = aws_elasticache_replication_group.replication_group.primary_endpoint_address
  description = "Address of the endpoint of the primary node in the replication group."
}

output "redis_replication_group_arn" {
  value       = aws_elasticache_replication_group.replication_group.arn
  description = "ARN of the created Redis replication group."
}

output "redis_password" {
  value       = aws_elasticache_replication_group.replication_group.auth_token
  description = "Auth token that is used to access the Redis replication group."
  sensitive   = true
}

output "redis_security_group_id" {
  value       = aws_elasticache_replication_group.replication_group.security_group_ids
  description = "List of security groups that are associated with the Redis replication group."
}

output "redis_security_group_name" {
  value       = try(aws_security_group.redis[0].name, null)
  description = "List of security groups that are associated with the Redis replication group."
}

output "redis_subnet_group_name" {
  value       = try(aws_elasticache_subnet_group.redis[0].name, null)
  description = "Redis subnet group that was created (if one wasn't specified)."
}

output "redis_subnet_group_id" {
  value       = try(aws_elasticache_subnet_group.redis[0].id, null)
  description = "Redis subnet group ID that was created (if one wasn't specified)."
}

output "redis_port" {
  value       = aws_elasticache_replication_group.replication_group.port
  description = "Port that the Redis cluster is listening on."
}

output "redis_security_group_ids" {
  value       = aws_elasticache_replication_group.replication_group.security_group_ids
  description = "List of security groups that are associated with the Redis replication group."
}