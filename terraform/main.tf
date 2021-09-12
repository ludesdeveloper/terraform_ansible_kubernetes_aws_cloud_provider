provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "cluster" {
  source       = "./kubernetes-cluster"
  cluster_name = var.cluster_name
}



output "master_public_ip" {
  value = module.cluster.master_public_ip
}

output "worker_0_public_ip" {
  value = module.cluster.worker_0_public_ip
}

output "worker_1_public_ip" {
  value = module.cluster.worker_1_public_ip
}
