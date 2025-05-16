// cloudfront.tf
resource "aws_cloudfront_distribution" "cf_elb_origin" {
  aliases = ["www.example-mzc.com"]
  
  origin {
    #domain_name = aws_lb.app_lb.dns_name
    domain_name = "origin.example-mzc.com"
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }


  # S3 오리진 (OAI 사용)
  origin {
    domain_name = aws_s3_bucket.content_bucket_oai.bucket_regional_domain_name
    origin_id   = "s3-oai-origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  
  # S3 오리진 (OAC 사용)
  origin {
    domain_name = aws_s3_bucket.content_bucket_oac.bucket_regional_domain_name
    origin_id   = "s3-oac-origin"
    
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }


  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""

  # 기본 캐시 동작 (ALB 오리진)
  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # S3 OAI 오리진 캐시 동작
  ordered_cache_behavior {
    path_pattern           = "/oai-content/*"
    target_origin_id       = "s3-oai-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # S3 OAC 오리진 캐시 동작
  ordered_cache_behavior {
    path_pattern           = "/oac-content/*"
    target_origin_id       = "s3-oac-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }



  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.origin_cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = "cf-elb-origin"
  }
}

// outputs.tf (추가)
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cf_elb_origin.domain_name
}
