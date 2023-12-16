# KEY_VAULT_NAME=heroeskv

# echo -e "Create an Azure Key Vault named $KEY_VAULT_NAME"
# az keyvault create \
# --resource-group $RESOURCE_GROUP \
# --name $KEY_VAULT_NAME \
# --location $LOCATION

# echo -e "Create an Azure Certificate Policy"
# az keyvault certificate policy create \
# --vault-name $KEY_VAULT_NAME \


# echo -e "Generate a certificate and store it in the Azure Key Vault"
# az keyvault certificate create \
# --vault-name $KEY_VAULT_NAME \
# --name $FRONTEND_CERTIFICATE_NAME \
# --policy "$(az keyvault certificate get-default-policy)"


echo -e "Create a frontend vm named $FRONTEND_VM_NAME with image $FRONTEND_VM_IMAGE"

FQDN_FRONTEND_VM=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-frontend-vm \
--nsg $FRONTEND_VM_NSG_NAME \
--size $VM_SIZE --query "fqdns" -o tsv)

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name Allow8080 \
--priority 1003 \
--destination-port-ranges 8080 \
--direction Inbound

# az network nsg rule create \
# --resource-group $RESOURCE_GROUP \
# --nsg-name $FRONTEND_VM_NSG_NAME \
# --name Allow443 \
# --priority 1003 \
# --destination-port-ranges 443 \
# --direction Inbound

echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--command-id RunPowerShellScript \
--scripts @scripts/install-tour-of-heroes-angular.ps1 \
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-web/releases/download/v1.1.0/dist.zip"

echo -e "You can connect using http://$FQDN_FRONTEND_VM"