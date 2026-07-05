variable "vpc_id" { type = string }
variable "private_subnets" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "instance_class" { type = string }
variable "backup_retention_days" { type = number }
variable "deletion_protection" { type = bool }
variable "environment" { type = string }

resource "aws_security_group" "rds" {
  name   = "${var.environment}-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [var.ecs_sg_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.environment}-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = var.instance_class
  db_name                 = "hotel_db"
  username                = "dbadmin"
  password                = "SuperSecretPassword123!"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  backup_retention_period = var.backup_retention_days
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.environment == "dev" ? true : false
}
