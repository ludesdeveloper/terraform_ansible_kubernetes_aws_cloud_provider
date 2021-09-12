cd ../terraform
echo 'Connect to Master, Worker0, Worker1? Please type "master", "worker0", "worker1"' 
read choosen_node
if [ $choosen_node == "master" ]
then
  ssh -i kubernetes-keypair ubuntu@$(terraform output --raw master_public_ip)
elif [ $choosen_node == "worker0" ]
then
  ssh -i kubernetes-keypair ubuntu@$(terraform output --raw worker_0_public_ip)
elif [ $choosen_node == "worker1" ]
then
  ssh -i kubernetes-keypair ubuntu@$(terraform output --raw worker_1_public_ip)
fi
