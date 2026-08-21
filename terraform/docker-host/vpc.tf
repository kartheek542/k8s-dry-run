module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = "eks-learning-vpc"
  cidr = "10.0.0.0/16"

  region = var.aws_region

  azs = ["ap-south-1a", "ap-south-1b"]
  public_subnets       = ["10.0.1.0/24"]
  enable_nat_gateway   = false
  enable_dns_hostnames = true
}
