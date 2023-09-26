resource "aws_elasticache_replication_group" "replication_group" {
  engine                     = var.redis_engine
  replication_group_id       = "${var.friendly_name_prefix}-redis-rep-group"
  description                = var.redis_replication_group_description
  engine_version             = var.redis_engine_version
  port                       = var.redis_port
  parameter_group_name       = var.redis_parameter_group_name
  node_type                  = var.redis_node_type
  num_cache_clusters         = length(var.redis_subnet_ids)
  multi_az_enabled           = var.redis_enable_multi_az
  automatic_failover_enabled = var.redis_enable_multi_az ? true : false
  subnet_group_name          = var.redis_subnet_group_name != null ? var.redis_subnet_group_name : aws_elasticache_subnet_group.redis[0].name
  security_group_ids         = length(var.redis_security_group_ids) > 0 ? var.redis_security_group_ids : [aws_security_group.redis[0].id]
  at_rest_encryption_enabled = var.redis_enable_encryption_at_rest && var.redis_kms_key_arn != "" ? true : false
  kms_key_id                 = var.redis_enable_encryption_at_rest && var.redis_kms_key_arn != "" ? var.redis_kms_key_arn : null
  transit_encryption_enabled = var.redis_enable_transit_encryption
  auth_token                 = var.redis_password
  snapshot_retention_limit   = 0
  apply_immediately          = true
  auto_minor_version_upgrade = true

  dynamic "log_delivery_configuration" {
    for_each = length(var.redis_log_group_name) > 0 ? [1] : [0]
    content {
      destination      = var.redis_log_group_name
      destination_type = "cloudwatch-logs"
      log_format       = "text"
      log_type         = "slow-log"
    }
  }

  tags = merge({ "Name" = "${var.friendly_name_prefix}-${var.product}-redis" }, var.common_tags)
}

resource "aws_security_group" "redis" {
  count = length(var.redis_security_group_ids) == 0 ? 1 : 0

  name_prefix = "${var.friendly_name_prefix}-${var.product}-redis"
  description = "Security group that will be used for redis"
  vpc_id      = var.vpc_id
}

resource "aws_elasticache_subnet_group" "redis" {
  count = var.redis_subnet_group_name == null ? 1 : 0

  name       = "${var.friendly_name_prefix}-${var.product}-redis"
  subnet_ids = var.redis_subnet_ids
}