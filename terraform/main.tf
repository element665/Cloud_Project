terraform {
  backend "s3" {
    # This bucket must be created manually before running terraform init
    # It must be globally unique.
    bucket = "element665-site-tfstate" 
    key    = "cloud-resume-challenge/terraform.tfstate"
    region = "eu-north-1"
  }
}

resource "aws_lambda_function" "visitor_counter" {
  function_name = "${var.project_name}-visitor-counter"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "main.py.zip"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_count_table.name
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket_prefix = "${var.project_name}-"
  
  tags = {
    Name = "${var.project_name}-frontend-bucket"
  }
}

resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "s3-oac"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      },
      {
        Sid       = "AllowCloudFrontServicePrincipalListBucket"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.frontend_bucket.arn
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# Get the hosted zone for the domain
data "aws_route53_zone" "main" {
  name         = "element665.site."
  private_zone = false
}

# Request an ACM certificate for the domain
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Create Route 53 record for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  provider = aws.us_east_1
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

# Validate the ACM certificate
resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Update CloudFront distribution to use the ACM certificate
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "s3-frontend-bucket"
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  origin {
    origin_id   = "api-gateway"
    domain_name = split("/", aws_api_gateway_stage.prod.invoke_url)[2]
    origin_path = "/${aws_api_gateway_stage.prod.stage_name}"

    custom_origin_config {
      origin_protocol_policy = "https-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for static website"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-frontend-bucket"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "api-gateway"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

# Create Route 53 A record to point domain to CloudFront distribution
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_api_gateway_rest_api" "visitor_api" {
  name        = "${var.project_name}-visitor-api"
  description = "API Gateway for the visitor counter Lambda function"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "visit"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  resource_id   = aws_api_gateway_resource.proxy_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.visitor_api.id
  resource_id             = aws_api_gateway_resource.proxy_resource.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.proxy_method,
  ]

  rest_api_id = aws_api_gateway_rest_api.visitor_api.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api_resource.id,
      aws_api_gateway_resource.proxy_resource.id,
      aws_api_gateway_method.proxy_method.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_api.id
  stage_name    = "prod"
}

resource "aws_lambda_permission" "apigw_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" suffix is to allow invocation from any method on any resource
  # within the API Gateway REST API. For more fine-grained control, you can
  # specify the exact resource path and method.
  source_arn = "${aws_api_gateway_rest_api.visitor_api.execution_arn}/*/*"
}

# ACM certificate for API Gateway custom domain (must be in us-east-1 if it's not the default region)
resource "aws_acm_certificate" "api_cert" {
  provider          = aws.us_east_1 # Ensure this is in us-east-1 for API Gateway custom domains
  domain_name       = "api.${var.domain_name}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 record for API Gateway ACM certificate validation
resource "aws_route53_record" "api_cert_validation" {
  provider = aws.us_east_1 # Ensure this is in us-east-1 for API Gateway custom domains
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => dvo
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}

# Validate the API Gateway ACM certificate
resource "aws_acm_certificate_validation" "api_cert" {
  provider                = aws.us_east_1 # Ensure this is in us-east-1 for API Gateway custom domains
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.api_cert_validation : record.fqdn]
}

# Custom domain for API Gateway
resource "aws_api_gateway_domain_name" "api_custom_domain" {
  domain_name     = "api.${var.domain_name}"
  certificate_arn = aws_acm_certificate_validation.api_cert.certificate_arn
}

# Base path mapping for the custom domain to the API Gateway stage
resource "aws_api_gateway_base_path_mapping" "api_path_mapping" {
  api_id      = aws_api_gateway_rest_api.visitor_api.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.api_custom_domain.id
}

# Route 53 A record to point the custom domain to API Gateway
resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.api_custom_domain.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "resume-lambda-dynamodb-policy"
  description = "IAM policy for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.visitor_count_table.arn
      },
      {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_dynamodb_table" "visitor_count_table" {
  name         = "${var.project_name}-visitor-count"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
 
  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "resume-visitor-count"
  }
}

output "website_url" {
  description = "The URL of the deployed static website via CloudFront"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "api_url" {
  description = "The URL of the API Gateway custom domain"
  value       = aws_api_gateway_domain_name.api_custom_domain.cloudfront_domain_name
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend assets"
  value       = aws_s3_bucket.frontend_bucket.id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}