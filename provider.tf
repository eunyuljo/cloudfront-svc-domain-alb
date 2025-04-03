# Terraform for VPC, EC2, ALB, Route53 for CloudFront Origin
provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}




