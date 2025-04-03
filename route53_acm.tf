data "aws_route53_zone" "primary" {
  name         = "example-mzc.com"
  private_zone = false
}

# ALB 용 도메인 생성 - Route 53 
resource "aws_route53_record" "origin_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "origin.example-mzc.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.app_lb.dns_name]
}

# CloudFront 용 도메인 - Route 53 
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.example-mzc.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_elb_origin.domain_name
    zone_id                = aws_cloudfront_distribution.cf_elb_origin.hosted_zone_id
    evaluate_target_health = false
  }
}

# 인증서 생성 - Cloudfront 용 ( us-east-1 ) 
resource "aws_acm_certificate" "origin_cert" {
  provider          = aws.us_east_1
  domain_name       = "www.example-mzc.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "CloudFront www.example-mzc.com-cert"
  }
}

# ACM for ALB (ap-northeast-2)
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "origin.example-mzc.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "ALB origin.example-mzc.com"
  }
}


# 검증 자동화 코드
# for_each 를 통해 도메인 검증 항목에 대해 반복 ( dvo = domain_validata_opptions ) 
# CNAME 정보를 가져와서 Route53 hosted zone 에 등록 
# ACM 검증값은 리전이 서로 달라도 동일하다. 

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.origin_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "origin" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.origin_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}