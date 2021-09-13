# Create Kubernetes that can Communicate via API with AWS Cloud Provider using Terraform and Ansible

## **What we want to achive?** 

Based on this repo

https://github.com/kubernetes/cloud-provider-aws

There are 3 things we can do with Cloud Provider AWS:

1. Creating Load Balancer from The Kubernetes it Self
2. Pulling ECR Private Repository
3. Attach EBS Volume from The Kubernetes

## **How we can do that?**

1. We need to put Tags in our EC2, it help kubernetes understand, that we deploy it on AWS
Key: kubernetes.io/cluster/kubernetes
Value: owned
2. We need add IAM Policy to EC2, so that AWS could create Load Balancer and mount EBS Volume on top of EC2. You can take a look all detail in terraform/kubernetes-cluster/modules/iam/main.tf
3. We need to add Tags in one of our Security Group, to let Cluster create Load Balancer
Key: kubernetes.io/cluster/kubernetes
Value: owned

**How to use all of these?**

I create all Terraform, Ansible, and also Scripts, to help you generate easily. I tried this on ubuntu 18.04, if you have different environment please check install-dependency script and update it

1. Go To Scripts Directory
```
cd scripts
```
