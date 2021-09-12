cd ..
master_public_ip=$(terraform output --raw master_public_ip)
worker_0_public_ip=$(terraform output --raw worker_0_public_ip)
worker_1_public_ip=$(terraform output --raw worker_1_public_ip)
cat > ../ansible/hosts <<EOF
[masters]
master ansible_host=$master_public_ip
[workers]
worker0 ansible_host=$worker_0_public_ip
worker1 ansible_host=$worker_1_public_ip
EOF
