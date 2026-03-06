# 1. Create the specific IAM role for your application pods
resource "aws_iam_role" "status_page_app_role" {
  name               = "ofek-status-page-app-s3-role"
  assume_role_policy = data.aws_iam_policy_document.status_page_app_trust.json
}

# 2. Define the specific S3 AND Secrets Manager permissions policy
resource "aws_iam_policy" "status_page_s3_policy" {
  name        = "ofek-status-page-s3-policy"
  description = "Allows the status page app to access S3 and read secrets from Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # S3 Permissions
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::ofek-status-page-assets-bucket-8849",
          "arn:aws:s3:::ofek-status-page-assets-bucket-8849/*"
        ]
      },
      {
        # NEW: Secrets Manager Permissions
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

# 3. Attach the S3 policy to the application role
resource "aws_iam_role_policy_attachment" "status_page_s3_attach" {
  role       = aws_iam_role.status_page_app_role.name
  policy_arn = aws_iam_policy.status_page_s3_policy.arn
}

# 4. Output the new Role ARN so we can easily copy it to Kubernetes
output "app_s3_role_arn" {
  value = aws_iam_role.status_page_app_role.arn
}

# 1. Define the trust relationship using the EXISTING OIDC provider from oidc.tf
data "aws_iam_policy_document" "status_page_app_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      # We dynamically take the URL from your existing oidc.tf resource
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:status-page-prod-sa"]
    }

    principals {
      # We dynamically take the ARN from your existing oidc.tf resource
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}