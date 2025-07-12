# 🔐 DB Password passed during apply
variable "db_password" {
  description = "The RDS database password"
  type        = string
  sensitive   = true
}

# 📡 List of public subnets for load balancers, NAT, etc.
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

# 🔒 List of private subnets for ECS, RDS, Redis
variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# 🌐 VPC where all resources will be created
variable "vpc_id" {
  description = "The VPC ID for the project"
  type        = string
}
