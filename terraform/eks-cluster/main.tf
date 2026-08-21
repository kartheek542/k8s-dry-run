terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change this to your preferred region
}

# ------------------------------------------------------------------------------
# 1. VPC Configuration (Cost-Optimized for Learning)
# ------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-learning-vpc"
  cidr = "10.0.0.0/16"

  # EKS requires at least 2 Availability Zones
  azs = ["us-east-1a", "us-east-1b"]
  
  # Deploying into public subnets allows us to avoid paying for a NAT Gateway
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway   = false
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

# ------------------------------------------------------------------------------
# 2. EKS Cluster Configuration
# ------------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "eks-learning-cluster"
  cluster_version = "1.30" 

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  # Minimal required add-ons for the cluster to actually function
  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # ------------------------------------------------------------------------------
  # 3. Spot Node Group
  # ------------------------------------------------------------------------------
  eks_managed_node_groups = {
    spot_nodes = {
      capacity_type  = "SPOT"
      instance_types = ["t3a.medium"] # 2 vCPU, 4GB RAM (Slightly cheaper than t3)
      
      min_size     = 1
      max_size     = 2
      desired_size = 1

      # Required since we are using public subnets without a NAT Gateway
      associate_public_ip_address = true
    }
  }

  # Automatically grants cluster admin access to the IAM identity running this code (e.g., your GitHub Actions role)
  enable_cluster_creator_admin_permissions = true
}
