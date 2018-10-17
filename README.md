# EKS cluster with New Relic monitoring
The purpose of this repository is to showcase how simple it can be to spin up an EKS cluster on AWS, deploy an app and monitor infrastructure, application and browser, and creating alerts using New Relic.

## EKS cluster
The cluster is spun up in its dedicated VPC, using a private topology and a single NAT-Gateway for access to the internet. The nodes will be created randomly in one of the three private availability zones, using T3 small spot instances, resulting in a much lower monthly bill.

In order to spin up a VPC, an EKS cluster, and an ECR, you'll have to have an AWS account and valid credentials stored in your `~/.aws/credentials` file. You'll also need **Terraform** installed which can be done with this command:

```bash
brew install terraform
```

Once, Terraform is installed, you can preview the resources that will be generated like this:

```bash
terraform plan -out terraform.plan
```

If the preview looks good, run the changes as below:

```bash
terraform apply terraform.plan
```

To interact with the cluster, you'll need to install the **AWS-IAM-Authenticator** and the **Kubernetes-CLI**. Here's one possible way to install them:

```bash
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/darwin/amd64/aws-iam-authenticator &&
chmod +x ./aws-iam-authenticator &&
mkdir -p $HOME/bin &&
mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && 
export PATH=$HOME/bin:$PATH &&
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bash_profile &&
brew install kubernetes-cli
```

## Infrastructure monitoring
The infrastructure is monitored with New Relic, leveraging the capabilities of the `kube-state-metrics` server, which can be installed like this:

```bash
curl -o kube-state-metrics-1.3.zip https://codeload.github.com/kubernetes/kube-state-metrics/zip/release-1.3 && 
unzip kube-state-metrics-1.3.zip && 
rm kube-state-metrics-1.3.zip &&
kubectl apply -f kube-state-metrics-release-1.3/kubernetes 
```

You'll have to insert a valid License key in the `newrelic-infrastructure-k8s-latest.yaml` file in order for it to work.

Once the `kube-state-metrics` server has been deployed and the YAML file has been updated, the New Relic infrastructure DaemonSet can be deployed like this:

```bash
kubectl apply -f newrelic-infrastructure-k8s-latest.yaml
```

You'll see metrics flowing into your New Relic account within 5 minutes.

## Application provisioning
The application is a simple HTML page running on PHP 5.6. THe user interaction is monitored by the browser agent of New Relic. 

Please note that the application is preconfigured with a New Relic Browser agent. If you intend to copy the PHP file, make sure to replace the script in the HTML header. Also, the `Dockerfile` doesn't contain a valid License Key for application monitoring, and may contain an application name you don't want. Make sure to update the values accordingly, before you use them.

The app has been build and pushed to AWS ECR with the `./build_and_push.sh` command and deployed with the command `kubectl apply -f hello-world-deployment.yaml`.

## Surfing the app
Once, everything has been provisioned and deployed, you can run this command to retrieve the URL where your app will be available:

```bash
kubectl get service | grep "hello-world" | awk {'print $4'}
```

## Alerting
The `alerts.tf` file will create alerts for the error rate of your application and the total page load time in a user's browser, and send a notification email to the indicated email address. Before it will work, you'll have to provide a valid API key and email address in the configuration.