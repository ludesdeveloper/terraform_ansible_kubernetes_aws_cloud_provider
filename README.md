# Create Kubernetes that can Communicate via API with AWS Cloud Provider using Terraform and Ansible

## **What we want to achive?** 

Based on this repo

https://github.com/kubernetes/cloud-provider-aws

There are 3 things we can do with cloud provider AWS:

1. Creating load balancer from the kubernetes it elf
2. Pulling ECR private repository
3. Attach EBS volume from the kubernetes

## **How we can do that?**

1. We need to put **tags** in our **EC2**, it help kubernetes understand, that we deploy it on AWS
Key: kubernetes.io/cluster/kubernetes
Value: owned
2. We need add **IAM policy** to **EC2**, so that AWS could create load balancer and mount EBS volume on top of EC2. You can take a look all detail in terraform/kubernetes-cluster/modules/iam/main.tf
3. We need to add **tags** in one of our **security group**, to let Cluster create Load Balancer
Key: kubernetes.io/cluster/kubernetes
Value: owned

## **How to use all of these?**

I create all Terraform, Ansible, and also Scripts, to help you generate easily. I tried this on ubuntu 18.04, if you have different environment please check install-dependency script and update it

1. Clone it first
```
git clone https://github.com/ludesdeveloper/terraform_ansible_kubernetes_aws_cloud_provider.git
```
2. Go To Scripts Directory
```
cd scripts
```
3. I assume we use Ubuntu fresh installed, so we need to install all dependencies
```
./install-dependencies.sh
```
4. Now we ready to create our infrastructure using terraform
```
./1-terraform-execute.sh
```

