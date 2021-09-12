echo "Please input access_key : "
read access_key
echo "Please input secret_key : "
read secret_key
echo "Please input cluster_name : "
read cluster_name 
cat > ../terraform.tfvars <<EOF
access_key = "$access_key"
secret_key = "$secret_key"
cluster_name = "$cluster_name"
EOF
