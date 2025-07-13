resource "aws_ecs_cluster" "medusa_cluster" {
  name = "medusa-cluster"
}

# Medusa Server Task Definition
resource "aws_ecs_task_definition" "medusa_server" {
  family                   = "medusa-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa-server"
      image     = "${aws_ecr_repository.medusa_backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "COOKIE_SECRET", value = "supersecret" },
        { name = "JWT_SECRET", value = "supersecret" },
        { name = "DISABLE_MEDUSA_ADMIN", value = "false" },
        { name = "MEDUSA_WORKER_MODE", value = "server" },
        { name = "PORT", value = "9000" },
        { name = "STORE_CORS", value = "http://yourstore.com" },
        { name = "ADMIN_CORS", value = "http://admin.medusa.com" },
        { name = "AUTH_CORS", value = "http://admin.medusa.com,http://yourstore.com" },
        { name = "MEDUSA_BACKEND_URL", value = "http://<alb-dns>:9000" },
        {
          name  = "DATABASE_URL",
          value = "postgresql://postgres:${var.db_password}@${aws_db_instance.medusa_postgres.endpoint}:5432/medusa-db"
        },
        {
          name  = "REDIS_URL",
          value = "redis://${aws_elasticache_cluster.medusa_redis.cache_nodes[0].address}:6379"
        }
      ]
    }
  ])
}

# Medusa Worker Task Definition
resource "aws_ecs_task_definition" "medusa_worker" {
  family                   = "medusa-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa-worker"
      image     = "${aws_ecr_repository.medusa_backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 9000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "COOKIE_SECRET", value = "supersecret" },
        { name = "JWT_SECRET", value = "supersecret" },
        { name = "DISABLE_MEDUSA_ADMIN", value = "true" },
        { name = "MEDUSA_WORKER_MODE", value = "worker" },
        { name = "PORT", value = "9000" },
        {
          name  = "DATABASE_URL",
          value = "postgresql://postgres:${var.db_password}@${aws_db_instance.medusa_postgres.endpoint}:5432/medusa-db"
        },
        {
          name  = "REDIS_URL",
          value = "redis://${aws_elasticache_cluster.medusa_redis.cache_nodes[0].address}:6379"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "medusa_server_service" {
  name            = "medusa-server-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_server.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_all.id] # <-- use real SG here
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa_tg.arn
    container_name   = "medusa-server"
    container_port   = 9000
  }

  depends_on = [aws_lb_listener.http_listener]
}

resource "aws_ecs_service" "medusa_worker_service" {
  name            = "medusa-worker-service"
  cluster         = aws_ecs_cluster.medusa_cluster.id
  task_definition = aws_ecs_task_definition.medusa_worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_all.id] # <-- use real SG here
  }
}
