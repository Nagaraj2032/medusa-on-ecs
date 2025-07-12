# Subnet group for Redis to define where Redis can be deployed
resource "aws_elasticache_subnet_group" "medusa_redis_subnet_group" {
  name       = "medusa-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "medusa-redis-subnet-group"
  }
}

# ElastiCache Redis cluster resource
resource "aws_elasticache_cluster" "medusa_redis" {
  cluster_id           = "medusa-redis-cluster"
  engine               = "redis"
  engine_version       = "6.x"                          # ✅ Matches parameter group
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  port                 = 6379
  parameter_group_name = "default.redis6.x"             # ✅ Must match Redis version
  subnet_group_name    = aws_elasticache_subnet_group.medusa_redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = {
    Name = "medusa-redis-cluster"
  }
}

