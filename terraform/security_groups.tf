# --- ALB Security Group ---
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from anywhere
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from anywhere
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-alb"
  }
}

# --- EKS Worker Nodes Security Group ---
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-sg-eks-nodes"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.main.id

  # Allow nodes to communicate with each other
  ingress {
    description = "Self-referencing rule for internal node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow all outbound traffic to download images/updates via NAT
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-eks-nodes"
  }
}

# Rule to allow ALB to talk to EKS Nodes on any port
resource "aws_security_group_rule" "eks_allow_alb" {
  type                     = "ingress"
  description              = "Allow traffic from ALB to EKS nodes"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.eks_nodes.id
}

  
  # This dynamically finds the cluster's default security group and attaches the rule to it
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

# --- RDS PostgreSQL Security Group ---
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "Security group for RDS PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL traffic ONLY from EKS nodes
  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"

    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Allow all outbound traffic (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-rds"
  }
}

# --- Redis Security Group ---
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-sg-redis"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.main.id

  # Allow Redis traffic ONLY from EKS nodes
  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"

    security_groups = [aws_security_group.eks_nodes.id]
  }

  # Allow all outbound traffic (default behavior)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-redis"
  }
}