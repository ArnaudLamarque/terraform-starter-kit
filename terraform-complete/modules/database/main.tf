resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.env}-db-subnet-group"
  subnet_ids = var.database_subnet_ids
  tags       = merge(var.tags, { Name = "${var.project}-${var.env}-db-subnet-group" })
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.env}-rds-sg"
  description = "RDS — allow from app tier only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.env}-rds-sg" })
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project}-${var.env}"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  manage_master_user_password = true # Password in Secrets Manager automatically

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  multi_az            = var.env == "prod" ? true : false
  deletion_protection = var.env == "prod" ? true : false
  skip_final_snapshot = var.env == "prod" ? false : true
  final_snapshot_identifier = var.env == "prod" ? "${var.project}-${var.env}-final" : null

  backup_retention_period = var.env == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  performance_insights_enabled = true

  tags = var.tags
}
