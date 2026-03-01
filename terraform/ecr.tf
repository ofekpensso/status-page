# Create an Amazon ECR repository to store the Status Page Docker images
resource "aws_ecr_repository" "status_page_repo" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"

  # Automatically scan Docker images for vulnerabilities when pushed
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Define a lifecycle policy to only keep the 10 most recent images and delete old ones
resource "aws_ecr_lifecycle_policy" "status_page_policy" {
  repository = aws_ecr_repository.status_page_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}