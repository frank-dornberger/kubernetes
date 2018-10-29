terraform {
  backend "s3" {
    bucket = "frank-terraform-state-bucket"
    key    = "kubernetes/dev.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "${var.region}"
}

provider "newrelic" {
  api_key = "${var.new_relic_api_key}"
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  workers_group_defaults = [
    {
      asg_desired_capacity = 1
      asg_max_size         = 10
      asg_min_size         = 1
      instance_type        = "t3.small"
      key_name             = "${aws_key_pair.provisioning_key.id}"

      # spot_price           = "0.01"
      root_volume_size    = "20"
      name                = "worker_group_a"
      additional_userdata = ""
    },
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.46.0"
  name    = "kubernetes-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/cluster/frank-cluster-1" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/frank-cluster-1" = "owned"
  }

  vpc_tags = {
    "kubernetes.io/cluster/frank-cluster-1" = "owned"
  }

  tags = "${merge(
    local.common_tags,
  )}"
}

resource "aws_key_pair" "provisioning_key" {
  key_name   = "provisioning_key"
  public_key = "${file("../../.ssh/provisioning_key.pub")}"
}

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "1.7.0"
  cluster_name                   = "frank-cluster-1"
  subnets                        = ["${module.vpc.private_subnets[0]}", "${module.vpc.private_subnets[1]}", "${module.vpc.private_subnets[2]}"]
  vpc_id                         = "${module.vpc.vpc_id}"
  create_elb_service_linked_role = true
  workers_group_defaults         = "${local.workers_group_defaults}"

  tags = "${merge(
    local.common_tags,
  )}"
}

resource "aws_ecr_repository" "hello_world" {
  name = "hello_world"
}
