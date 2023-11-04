
resource "aws_security_group" "security_group_redis" {
  name        = "${var.environment}-redis-sg"
  description = "Provides access to the Redis Elasticache cluster."

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    description = "Production VPC CIDR"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    description = "Gateway CIDR"
    cidr_blocks = var.gateway_cidr
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    description = "Ecs VPC CIDR"
    cidr_blocks = [var.vpc_cidr_ecs]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment}-redis-sg" }), var.tags)
}

resource "aws_elasticache_cluster" "redis_dd" {
  cluster_id           = "${var.environment}-dd-redis"
  engine               = "redis"
  engine_version       = "4.0.10"
  node_type            = "cache.m5.xlarge"
  port                 = 6379
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group_redis_dd.id
  parameter_group_name = "default.redis4.0"
  availability_zone    = "eu-west-1a"
  security_group_ids   = [aws_security_group.security_group_redis.id]
}

resource "aws_elasticache_cluster" "redis_dd_prev" {
  cluster_id           = "${var.environment}-redis-prev"
  engine               = "redis"
  engine_version       = "5.0.6"
  node_type            = "cache.t3.medium"
  port                 = 6379
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.subnet_group_redis_dd.id
  parameter_group_name = "default.redis5.0"
  availability_zone    = "eu-west-1a"
  security_group_ids   = [aws_security_group.security_group_redis.id]
}

resource "aws_elasticache_replication_group" "redis_us" {
  replication_group_id       = "${var.environment}-user-session"
  description                = "${var.environment} User Service session repo replication group"
  node_type                  = "cache.t2.medium"
  num_cache_clusters         = 2
  port                       = 6379
  parameter_group_name       = "default.redis4.0.cluster.on"
  multi_az_enabled           = true
  automatic_failover_enabled = true
  security_group_ids         = [aws_security_group.security_group_redis.id]
  subnet_group_name          = aws_elasticache_subnet_group.subnet_group_redis_us.name
  tags                       = merge(tomap({ "Name" = "${var.environment}-user-session" }), var.tags)
}

resource "aws_elasticache_subnet_group" "subnet_group_redis_dd" {
  name        = "${var.environment}-daily-deals-redis-subnet-group"
  description = "${var.environment} Daily Deals Redis subnet group"
  subnet_ids  = [module.vpc.public_subnets[0]]
}

resource "aws_elasticache_subnet_group" "subnet_group_redis_us" {
  name        = "${var.environment}-user-service-redis-cache-subnet"
  description = "${var.environment}-user-session Redis subnet group"
  subnet_ids  = module.vpc.private_subnets
}