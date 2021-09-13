cd ../../terraform
masterip=$(terraform output --raw master_public_ip)
cd ..
cp ansible/master/home/ubuntu/admin.conf deployments/scripts/admin.conf
cd deployments/scripts
python3 replace_ip_admin_conf.py $masterip
mv config ../config
