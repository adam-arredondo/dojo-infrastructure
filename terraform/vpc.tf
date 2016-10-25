provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"
  name = "VPC-A1"
  cidr = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  azs      = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Create NAT gateway based on public subnet IDs from vpc module
module "private_subnet" {
  source             = "github.com/terraform-community-modules/tf_aws_private_subnet_nat_gateway"
  name               = "dev-private"
  vpc_id             = "${module.vpc.vpc_id}"
  cidrs              = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_ids  = ["${module.vpc.public_subnets[0]}","${module.vpc.public_subnets[2]}","${module.vpc.public_subnets[2]}"]
  nat_gateways_count = 1    # can be between 1 and "number of public subnets".
  depends_on = ["${module.vpc.public_subnets[0]}"]
}
