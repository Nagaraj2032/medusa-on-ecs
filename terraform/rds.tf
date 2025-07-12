resource "aws_db_subnet_group" "medusa_db_subnet_group" {
  name       = "medusa-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "Medusa DB Subnet Group"
  }
}

resource "aws_db_instance" "medusa_postgres" {
  identifier              = "medusa-postgres-db"               # Can have dashes
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "postgres"
  password                = var.db_password
  db_name                 = "medusadb"                         # ✅ Alphanumeric only
  port                    = 5432
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.medusa_db_subnet_group.name

  tags = {
    Name = "Medusa Postgres DB"
  }
}
