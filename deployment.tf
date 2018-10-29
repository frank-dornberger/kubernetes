resource "null_resource" "set_kubeconfig" {
  provisioner "local-exec" {
    command = "echo 'export KUBECONFIG=./kubeconfig_frank-cluster-1' > .env && source .env"
  }
}

resource "null_resource" "ecr_login" {
  depends_on = ["aws_ecr_repository.hello_world"]

  provisioner "local-exec" {
    command = "$(aws ecr get-login --no-include-email --region eu-west-1)"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "increase_version" {
  provisioner "local-exec" {
    command = "expr $(cat Version) + 1 > Version"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "docker_build" {
  depends_on = ["null_resource.increase_version"]

  provisioner "local-exec" {
    command = "docker build -t hello_world:${chomp(file("Version"))} ."
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "docker_tag" {
  depends_on = ["aws_ecr_repository.hello_world", "null_resource.docker_build"]

  provisioner "local-exec" {
    command = "docker tag hello_world:${chomp(file("Version"))} ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "docker_push" {
  depends_on = ["null_resource.docker_tag", "null_resource.ecr_login"]

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "complete_deploy_file" {
  depends_on = ["null_resource.increase_version"]

  provisioner "local-exec" {
    command = "sed -i '' 's@image.*@image: ${aws_ecr_repository.hello_world.repository_url}:${chomp(file("Version"))}@g' hello-world-deployment.yaml"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "deploy_application" {
  depends_on = ["module.eks", "null_resource.docker_push", "null_resource.complete_deploy_file"]

  provisioner "local-exec" {
    command = "kubectl apply -f hello-world-deployment.yaml --kubeconfig ./kubeconfig_frank-cluster-1"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
  }
}

resource "null_resource" "validate_deployment" {
  depends_on = ["null_resource.deploy_application"]

  provisioner "local-exec" {
    command = "open http://$(kubectl get service --kubeconfig ./kubeconfig_frank-cluster-1 | grep hello-world | awk {'print $4'})"
  }

  triggers = {
    page_sha1      = "${sha1(file("public/index.php"))}"
    container_sha1 = "${sha1(file("Dockerfile"))}"
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

  triggers = {
    page_sha1 = "${sha1(file("newrelic-infrastructure-k8s-latest.yaml"))}"
  }
}
