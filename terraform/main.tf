// Terraform AWS provider and EKS module stub
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

// VPC module - creates networking
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

data "aws_availability_zones" "available" {}

// EKS cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  # Attach to the VPC created above
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Node groups can be added later or managed outside this module. Keep the module minimal here.
}

// ECR repositories - create repos for frontend/backends
resource "aws_ecr_repository" "frontend" {
  name = "${var.ecr_repos.frontend}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "backend" {
  name = "${var.ecr_repos.backend}"
  image_tag_mutability = "MUTABLE"
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_name_output" {
  value       = module.eks.cluster_id
  description = "EKS cluster id"
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "ecr_frontend_repo" {
  value = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repo" {
  value = aws_ecr_repository.backend.repository_url
}
