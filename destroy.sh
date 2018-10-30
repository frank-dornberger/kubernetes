#!/bin/bash
kubectl delete -f hello-world-deployment.yaml --kubeconfig ./kubeconfig_frank-cluster-1
echo "hello-world app removed"
terraform destroy -auto-approve
unset KUBECONFIG
echo "Infrastructure and monitoring removed"
