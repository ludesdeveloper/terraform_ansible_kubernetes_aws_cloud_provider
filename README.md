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
cd terraform_ansible_kubernetes_aws_cloud_provider/scripts
```
3. I assume we use Ubuntu fresh installed, so we need to install all dependencies
```
./install-dependencies.sh
```
4. Now we ready to create our infrastructure using terraform
```
./1-terraform-execute.sh
```
5. You'll be asked for 'Do you want to re-initiate terraform.tfvars file? Please type "yes" or "no"'. Please type "yes", then hit enter
6. You'll be asked for 'Please input access_key :'. Input your access_key, you can get it from your AWS IAM, then hit enter
7. You'll be asked for 'Please input secret_key :'. Input your secret_key, you can get it from your AWS IAM also, then hit enter
8. You'll be asked for 'Please input cluster_name :'. Please give name to your cluster then hit enter
9. You'll be asked for 'Do you want to re-generate keypair? Please type "yes" or "no"'. Please type "yes" then hit enter
10. You'll be asked for 'Enter passphrase (empty for no passphrase):'. You can leave it empty or adding passphrase then hit enter
11. You'll be asked for 'Enter same passphrase again:'. You can leave it empty or re type the same passphrase then hit enter
12. It will take a while, and then generating output
13. After generating output, go to your AWS EC2 console in web, make sure your region is set to us-east-1. Take a look you instance, then wait until Status check is 2/2 checks passed	
 for all nodes 

