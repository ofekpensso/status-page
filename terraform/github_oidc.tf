## terraform/github_oidc.tf
# 2. Define the Trust Policy (Who is allowed to assume this role)
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    principals {
      type        = "Federated"
      # Notice we now use the 'data' source instead of 'resource'
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    
    # SECURITY: Restrict access ONLY to your specific GitHub repository!
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:ofekpensso/status-page:*"]
    }
  }
}

# 3. Create the IAM Role using the trust policy
resource "aws_iam_role" "github_actions_role" {
  name               = "GitHubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# 4. Attach the AmazonEC2ContainerRegistryPowerUser policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_ecr_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 5. Output the Role ARN so we can easily copy it to our GitHub Actions YAML
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions_role.arn
  description = "The ARN of the IAM Role to use in the GitHub Actions workflow"
}