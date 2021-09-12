terraform {
  required_version = ">= 0.12"
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

#------------------------------------------------------------------------------#
# Common local values
#------------------------------------------------------------------------------#

locals {
  cluster_name = var.cluster_name
  tags         = merge(var.tags, { "terraform-kubeadm:cluster" = local.cluster_name })
}

#------------------------------------------------------------------------------#
# Key pair
#------------------------------------------------------------------------------#

# Performs 'ImportKeyPair' API operation (not 'CreateKeyPair')
resource "aws_key_pair" "main" {
  key_name_prefix = "${local.cluster_name}-"
  public_key      = file(var.public_key_file)
  tags            = local.tags
}

#------------------------------------------------------------------------------#
# Security groups
#------------------------------------------------------------------------------#

# The AWS provider removes the default "allow all "egress rule from all security
# groups, so it has to be defined explicitly.
resource "aws_security_group" "egress" {
  name        = "${local.cluster_name}-egress"
  description = "Allow all outgoing traffic to everywhere"
  vpc_id      = var.vpc_id
  tags        = local.tags
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress_internal" {
  name        = "${local.cluster_name}-ingress-internal"
  description = "Allow all incoming traffic from nodes and Pods in the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    self        = true
    description = "Allow incoming traffic from cluster nodes"

  }
  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.pod_network_cidr_block != null ? [var.pod_network_cidr_block] : null
    description = "Allow incoming traffic from the Pods of the cluster"
  }
}

resource "aws_security_group" "ingress_k8s" {
  name        = "${local.cluster_name}-ingress-k8s"
  description = "Allow incoming Kubernetes API requests (TCP/6443) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = var.allowed_k8s_cidr_blocks
  }
}

resource "aws_security_group" "ingress_ssh" {
  name        = "${local.cluster_name}-ingress-ssh"
  description = "Allow incoming SSH traffic (TCP/22) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = local.tags
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }
}

resource "aws_security_group" "ingress_external" {
  name        = "${local.cluster_name}-ingress-external"
  description = "Allow incoming requests (Still All Request / All Port) from outside the cluster"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { "kubernetes.io/cluster/kubernetes" = "owned" })

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#------------------------------------------------------------------------------#
# Elastic IP for master and worker node
#------------------------------------------------------------------------------#

resource "aws_eip" "master" {
  vpc  = true
  tags = local.tags
}

resource "aws_eip_association" "master" {
  allocation_id = aws_eip.master.id
  instance_id   = aws_instance.master.id
}

resource "aws_eip" "workers" {
  count = 2
  vpc   = true
  tags  = local.tags
}

resource "aws_eip_association" "workers" {
  count         = 2
  allocation_id = aws_eip.workers[count.index].id
  instance_id   = aws_instance.workers[count.index].id
}

#------------------------------------------------------------------------------#
# EC2 instances
#------------------------------------------------------------------------------#

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # AWS account ID of Canonical
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "master" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.master_instance_type
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_k8s.id,
    aws_security_group.ingress_ssh.id,
    aws_security_group.ingress_external.id
  ]

  iam_instance_profile = "${var.cluster_name}-kubernetes-cluster-master-iam-role"
  tags                 = merge({ "Name" = "${var.cluster_name}-master" }, local.tags, { "terraform-kubeadm:node" = "master" }, { "kubernetes.io/cluster/kubernetes" = "owned" })

  root_block_device {
    volume_size = 35
  }
}

resource "aws_instance" "workers" {
  count                       = var.num_workers
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = var.worker_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids = [
    aws_security_group.egress.id,
    aws_security_group.ingress_internal.id,
    aws_security_group.ingress_ssh.id,
    aws_security_group.ingress_external.id
  ]
  iam_instance_profile = "${var.cluster_name}-kubernetes-cluster-worker-iam-role"
  tags                 = merge({ "Name" = "${var.cluster_name}-worker-${count.index}" }, local.tags, { "terraform-kubeadm:node" = "worker-${count.index}" }, { "kubernetes.io/cluster/kubernetes" = "owned" })

  root_block_device {
    volume_size = 35
  }
}
