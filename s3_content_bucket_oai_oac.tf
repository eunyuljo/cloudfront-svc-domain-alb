// S3 버킷 생성
resource "aws_s3_bucket" "content_bucket_oai" {
  bucket = "example-mzc-oai-bucket"
  
  tags = {
    Name = "OAI Example Bucket"
  }
}

resource "aws_s3_bucket" "content_bucket_oac" {
  bucket = "example-mzc-oac-bucket"
  
  tags = {
    Name = "OAC Example Bucket"
  }
}

// S3 퍼블릭 액세스 차단 설정 (보안 모범 사례)
resource "aws_s3_bucket_public_access_block" "oai_bucket_access_block" {
  bucket = aws_s3_bucket.content_bucket_oai.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "oac_bucket_access_block" {
  bucket = aws_s3_bucket.content_bucket_oac.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// 1. OAI 접근 방식 (레거시)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for S3 access"
}

// OAI용 S3 버킷 정책
data "aws_iam_policy_document" "s3_policy_oai" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.content_bucket_oai.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "oai_bucket_policy" {
  bucket = aws_s3_bucket.content_bucket_oai.id
  policy = data.aws_iam_policy_document.s3_policy_oai.json
}


// 2. OAC 접근 방식 (권장)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "example-oac"
  description                       = "OAC for S3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

// OAC용 S3 버킷 정책 - CloudFront 배포 생성 후에 적용
data "aws_iam_policy_document" "s3_policy_oac" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.content_bucket_oac.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cf_elb_origin.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "oac_bucket_policy" {
  bucket = aws_s3_bucket.content_bucket_oac.id
  policy = data.aws_iam_policy_document.s3_policy_oac.json
  # S3 버킷 정책은 CloudFront 배포 생성 후에 적용되어야 함
  depends_on = [aws_cloudfront_distribution.cf_elb_origin]
}

// S3 관련 출력 값
output "s3_oai_bucket_name" {
  value = aws_s3_bucket.content_bucket_oai.bucket
}

output "s3_oac_bucket_name" {
  value = aws_s3_bucket.content_bucket_oac.bucket
}

output "oai_identity_path" {
  value = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
}

output "oac_id" {
  value = aws_cloudfront_origin_access_control.oac.id
}
