resource "aws_route53_zone" "primary" {
  force_destroy = "false"
  name          = var.domain
}

resource "aws_route53_record" "cloudfront" {
  alias {
    evaluate_target_health = "false"
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
  }

  name    = var.domain
  type    = "A"
  zone_id = aws_route53_zone.primary.zone_id
}

resource "aws_route53_record" "cloudfront" {
  alias {
    evaluate_target_health = "false"
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
  }

  name    = "www.${var.domain}"
  type    = "A"
  zone_id = aws_route53_zone.primary.zone_id
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.cf_ssl.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.primary.zone_id
}
