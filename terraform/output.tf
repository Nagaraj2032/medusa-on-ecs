output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}
output "ecr_repository_url" {
  description = "URI of the ECR repository"
  value       = aws_ecr_repository.medusa_backend.repository_url
}
output "rds_endpoint" {
  value = aws_db_instance.medusa_postgres.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.medusa_redis.cache_nodes[0].address
}
