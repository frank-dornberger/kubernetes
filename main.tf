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
      spot_price           = "0.01"
      root_volume_size     = "20"
      name                 = "worker_group_a"
      additional_userdata  = ""
    },
  ]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "kubernetes-vpc"
  cidr = "10.0.0.0/16"

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

# Warum geht source .env nicht???
resource "null_resource" "set_kubeconfig" {
  depends_on = ["module.eks"]

  provisioner "local-exec" {
    command = "touch .env && echo 'export KUBECONFIG=./kubeconfig_frank-cluster-1' > .env"
  }
}

resource "null_resource" "ecr_login" {
  depends_on = ["aws_ecr_repository.hello_world"]

  provisioner "local-exec" {
    command = "$(aws ecr get-login --no-include-email --region eu-west-1)"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "increase_version" {
  provisioner "local-exec" {
    command = "expr $(cat Version) + 1 > Version"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "docker_build" {
  depends_on = ["null_resource.increase_version"]

  provisioner "local-exec" {
    command = "docker build -t hello_world:${chomp(file("Version"))} ."
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "docker_tag" {
  depends_on = ["aws_ecr_repository.hello_world", "null_resource.docker_build"]

  provisioner "local-exec" {
    command = "docker tag hello_world:${chomp(file("Version"))} ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "docker_push" {
  depends_on = ["null_resource.docker_tag"]

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "complete_deploy_file" {
  depends_on = ["null_resource.increase_version"]

  provisioner "local-exec" {
    command = "sed -i '' 's@image.*@image: ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}@g' hello-world-deployment.yaml"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "deploy_application" {
  depends_on = ["module.eks", "null_resource.docker_push", "null_resource.complete_deploy_file"]

  provisioner "local-exec" {
    command = "kubectl apply -f hello-world-deployment.yaml --kubeconfig ./kubeconfig_frank-cluster-1"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "validate_deployment" {
  depends_on = ["null_resource.deploy_application"]

  provisioner "local-exec" {
    command = "open http://$(kubectl get ingress -n lpt | grep top-deals | awk {'print $3'})"
  }

  triggers = {
    page_sha1 = "${sha1(file("public/index.php"))}"
  }
}

resource "null_resource" "deploy_monitoring_dependencies" {
  depends_on = ["module.eks"]

  provisioner "local-exec" {
    command = "kubectl apply -f kube-state-metrics-release-1.3/kubernetes --kubeconfig ./kubeconfig_frank-cluster-1"
  }
}

resource "null_resource" "deploy_monitoring" {
  depends_on = ["module.eks", "null_resource.deploy_monitoring_dependencies"]

  provisioner "local-exec" {
    command = "kubectl apply -f newrelic-infrastructure-k8s-latest.yaml --kubeconfig ./kubeconfig_frank-cluster-1"
  }
}
