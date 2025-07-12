resource "aws_ecr_repository" "medusa_backend" {
  name                 = "medusa-backend"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "medusa-backend"
  }
}
