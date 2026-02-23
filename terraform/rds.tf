# Create a DB subnet group using the private data subnets
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_data_a.id, aws_subnet.private_data_b.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# Create the PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-rds"
  engine                 = "postgres"
  engine_version         = "15" 
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  
  db_name                = "statuspage"
  username               = "statuspage"
  password               = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  publicly_accessible    = false
  skip_final_snapshot    = true 

  tags = {
    Name = "${var.project_name}-rds"
  }
}