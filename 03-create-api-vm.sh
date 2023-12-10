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

echo -e "Create a network security group rule for port 80"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $API_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

# https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-7.0&tabs=linux-ubuntu
echo -e "Execute script to install nginx, .NET Core, deploy the app and create the service"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--command-id RunShellScript \
--scripts @scripts/install-tour-of-heroes-api.sh \
--parameters https://github.com/0GiS0/tour-of-heroes-dotnet-api/releases/download/1.0.5/drop.zip $FQDN_API_VM $DB_VM_ADMIN_USERNAME $DB_VM_ADMIN_PASSWORD

echo -e "You can connect using http://$FQDN_API_VM"
