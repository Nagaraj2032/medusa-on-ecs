# security.tf

resource "aws_security_group" "allow_all" {
  name        = "medusa-allow-all"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = var.vpc_id # <- Make sure `vpc_id` is declared in your variables

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere (for testing only)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
