resource "aws_cloudfront_distribution" "s3_distribution" {
  aliases     = var.domain_names
  price_class = "PriceClass_All"

  origin {
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf_origin.id
    origin_id                = aws_s3_bucket.bucket.bucket_regional_domain_name
  }

  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress                 = true
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    target_origin_id         = aws_s3_bucket.bucket.bucket_regional_domain_name
    viewer_protocol_policy   = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = "arn:aws:cloudfront::786150492747:function/router"
    }
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cf_ssl.arn
    cloudfront_default_certificate = false
    iam_certificate_id             = null
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_cloudfront_origin_access_control" "cf_origin" {
  name                              = aws_s3_bucket.bucket.bucket_regional_domain_name
  description                       = null
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "cf_ssl" {
  provider = aws.us_east_1

  certificate_authority_arn = null
  domain_name               = var.domain
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_acm_certificate_validation" "cert_validation" {
  provider = aws.us_east_1
  timeouts {
    create = "5m"
  }
  certificate_arn         = aws_acm_certificate.cf_ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}


