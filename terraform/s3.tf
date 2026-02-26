# --- Amazon S3 for Static Assets (Photos & HTML) ---
resource "aws_s3_bucket" "status_page_assets" {
  # S3 bucket names must be globally unique across all AWS accounts
  # Change the random numbers at the end to make sure it's unique
  bucket = "${var.project_name}-assets-bucket-8849" 
}

# Enable versioning to keep a history of deleted or modified files
resource "aws_s3_bucket_versioning" "assets_versioning" {
  bucket = aws_s3_bucket.status_page_assets.id
  versioning_configuration {
    status = "Enabled"
  }
}