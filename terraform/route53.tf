# Create a Route 53 Hosted Zone to manage the DNS records for your new domain
resource "aws_route53_zone" "main" {
  name = "oag-status-page-devops.site"
}

# Output the generated Name Servers (NS) so you can easily copy them to Namecheap
output "domain_name_servers" {
  value       = aws_route53_zone.main.name_servers
  description = "The 4 NS records you need to paste into the Custom DNS settings in Namecheap"
}

# Request a free SSL certificate from AWS ACM for your domain
resource "aws_acm_certificate" "cert" {
  domain_name       = "oag-status-page-devops.site"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Create the DNS record in Route53 to prove to AWS that you own the domain
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Tell Terraform to wait for the certificate validation to complete successfully
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Output the Certificate ARN so we can copy it into our Kubernetes Ingress later
output "acm_certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

# Fetch the existing Application Load Balancer created by the Kubernetes controller
data "aws_lb" "status_page_alb" {
  name = "ofek-status-page-alb"
}

# Create an Alias record to point your root domain directly to the ALB
resource "aws_route53_record" "root_domain" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "oag-status-page-devops.site"
  type    = "A"

  alias {
    name                   = data.aws_lb.status_page_alb.dns_name
    zone_id                = data.aws_lb.status_page_alb.zone_id
    evaluate_target_health = true
  }
}