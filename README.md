# Create Self Managed Kubernetes that can Communicate via API with AWS Cloud Provider using Terraform and Ansible

## **What We Want to Achive?** 

Based on this repo

https://github.com/kubernetes/cloud-provider-aws

There are 3 things we can do with cloud provider AWS:

1. Creating load balancer from the kubernetes it self
2. Pulling ECR private repository
3. Attach EBS volume from the kubernetes

## **How We Can Do That?**

1. We need to put **tags** in our **EC2**, it help kubernetes understand, that we deploy it on AWS. "Key: kubernetes.io/cluster/kubernetes, Value: owned"
2. We need add **IAM policy** to **EC2**, so that AWS could create load balancer and mount EBS volume on top of EC2. You can take a look all detail in terraform/kubernetes-cluster/modules/iam/main.tf
3. We need to add **tags** in one of our **security group**, to let Cluster create Load Balancer. "Key: kubernetes.io/cluster/kubernetes, Value: owned"

## **How to Use All of These?**

I create all Terraform, Ansible, and also Scripts, to help you generate cluster easily. I try to run these scripts on ubuntu 18.04, if you have different environment please check install-dependency.sh script and update it

1. Clone it first
```
git clone https://github.com/ludesdeveloper/terraform_ansible_kubernetes_aws_cloud_provider.git
```
2. Go to scripts directory
```
cd terraform_ansible_kubernetes_aws_cloud_provider/scripts
```
3. I assume we use ubuntu fresh installed, so we need to install all dependencies
```
./install-dependencies.sh
```
4. Now we ready to create our infrastructure using terraform
```
./1-terraform-execute.sh
```
5. You'll be asked for 'Do you want to re-initiate terraform.tfvars file? Please type "yes" or "no"'. Please type "yes", then hit enter
6. 'Please input access_key :'. Input your access_key, you can get it from your AWS IAM, then hit enter
7. 'Please input secret_key :'. Input your secret_key, you can get it from your AWS IAM also, then hit enter
8. 'Please input cluster_name :'. Please give name to your cluster then hit enter
9. You'll be asked for 'Do you want to re-generate keypair? Please type "yes" or "no"'. Please type "yes" then hit enter
10. 'Enter passphrase (empty for no passphrase):'. You can leave it empty or adding passphrase then hit enter
11. 'Enter same passphrase again:'. You can leave it empty or re type the same passphrase then hit enter
12. It will take a while, and then generating output
13. After generating output, go to your AWS EC2 console in web, make sure your region is set to **"us-east-1"**. Take a look you instance, then **wait** until Status check is **"2/2 checks passed"**	
 for all nodes 
14. Now we ready to install kubernetes using ansible on our created EC2 instances
```
./2-ansible-execute.sh
```
15. It will take a while, just wait until finish
16. Now we need to copy admin.conf from our cluster to our Ubuntu PC, just run this script below
```
./3-generate-kubeconfig.sh
```
17. Congratulation, now you have your cluster ready, check with this command below
```
kubectl get nodes
```

## **Testing Cluster**

I made several file deployment that you can use for your testing.

### **Load Balancer Testing**

1. Go to deployments folder
2. Apply load-balancer-deployment.yaml
```
kubectl apply -f load-balancer-deployment.yaml
```
3. Check your service with command below
```
kubectl get svc
```
4. You'll get your external ip for you load balancer, you need to make sure in AWS EC2 console section load balancer that instances of loadbalancer is ready then you can curl to it

### **Volume Attachment Testing**

1. Before you begin to testing volume attachment, you need to create EBS, and make sure your EBS having same **Availability Zone**
2. After create new EBS, copy **Volume ID**
3. You can edit file volume-deployment.yaml in section below, change it with your volume_id
```
  awsElasticBlockStore:
    volumeID: volume_id 
    fsType: ext4
```
4. Now you can apply with this command below
```
kubectl apply -f volume-deployment.yaml
```
5. You can check with command below for all StorageClass, PersistenceVolume, and PersistenceVolumeClaim that we create
```
kubectl get sc
kubectl get pv
kubectl get pvc
```
6. You can check where the volume mounted with this command 
```
kubectl get pods -o wide
```

### **Pull ECR Private Repo**

1. Before you begin, you need to have ECR Private Repo that ready to pull
2. You can edit ecr-private-deployment.yaml file. update ecr_private_url with your ECR Private URL
```
      containers:
      - name: ecr-private
        image: ecr_private_url
        ports:
        - containerPort: 80
```
3. Now you can apply with this command
```
kubectl apply -f ecr-private-deployment.yaml
```

## **Cleaning Up**

1. To clean up all things we have created we can go to root folder then go to Scripts, then execute this script below. 
```
./terraform-destroy-all.sh
```
2. Go to AWS EC2 console -> Elastic Block Store -> Volume, you need to clean up manually EBS that you create
3. Go to AWS EC2 console -> Load Balancing -> Load Balancers, you need to clean up manually load balancer that create by cluster service
4. Go to AWS EC2 console ->  Network & Security -> Security Groups, you need to clean up manually security groups that create by cluster service
