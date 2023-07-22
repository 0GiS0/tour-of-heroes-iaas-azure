echo -e "Create an api vm named $API_VM_NAME with image $API_VM_IMAGE"

FQDN_API_VM=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--image $API_VM_IMAGE \
--admin-username $API_VM_ADMIN_USERNAME \
--admin-password $API_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $API_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-api-vm \
--nsg $API_VM_NSG_NAME \
--size $VM_SIZE --query "fqdns" -o tsv)

echo -e "Api VM created"
echo -e "You can connect using $FQDN_API_VM"

echo -e "Create a network security group rule for ssh port 22"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $API_VM_NSG_NAME \
--name AllowSsh \
--priority 1001 \
--destination-port-ranges 22 \
--direction Inbound

echo -e "Create a network security group rule for port 80"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $API_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

echo -e "Create var/www/tour-of-heroes-api directory on the api vm"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--command-id RunShellScript \
--scripts "sudo mkdir -p /var/www/tour-of-heroes-api && sudo chown -R $API_VM_ADMIN_USERNAME:$API_VM_ADMIN_USERNAME /var/www/tour-of-heroes-api && sudo chmod -R 755 /var/www/tour-of-heroes-api"

# echo -e "Download the api app from github"
# gh repo clone 0GiS0/tour-of-heroes-dotnet-api

echo -e "Build the api app"
dotnet publish tour-of-heroes-dotnet-api --configuration Debug

# # Copy the app to the api vm
# echo -e "Copy the api app to the api vm"
scp -r tour-of-heroes-dotnet-api/bin/Debug/net7.0/publish/. $API_VM_ADMIN_USERNAME@$FQDN_API_VM:/var/www/tour-of-heroes-api/

# https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-7.0&tabs=linux-ubuntu
echo -e "Execute script to install nginx, .NET Core and create the service"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--command-id RunShellScript \
--scripts @scripts/install-tour-of-heroes-api.sh

ssh $API_VM_ADMIN_USERNAME@$FQDN_API_VM