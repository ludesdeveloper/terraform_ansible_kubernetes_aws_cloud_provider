cd ../terraform
echo 'Do you want to re-initiate terraform.tfvars file? Please type "yes" or "no"'
read tfvars_answer
if [ $tfvars_answer == "yes" ]
then
  cd scripts
  ./terraform-tfvars.sh
  cd ..
fi
terraform init
terraform apply -input=false -auto-approve
cd scripts
./ansible-hosts.sh
