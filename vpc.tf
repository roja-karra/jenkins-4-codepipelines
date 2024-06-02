# Eks cluster networking - Declaring the VPC module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks_vpc"
  cidr = var.vpc_cidr

  azs = var.aws_availability_zones
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets


  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/revhire-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/revhire-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/revhire-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"

  }
  map_public_ip_on_launch = true

}
