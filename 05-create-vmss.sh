# https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/quick-create-cli
VMSS_NAME="frontend-vmss"

echo -e "Create a scale set for the front end"
az vmss create \
--resource-group $RESOURCE_GROUP \
--name $VMSS_NAME \
--image $FRONTEND_VM_IMAGE \
--upgrade-policy-mode automatic \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD 


# Configure tour-of-heroes-angular SPA
echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"

# For each VM in the scale set
for VM_NAME in $(az vmss list-instances --resource-group $RESOURCE_GROUP --name $VMSS_NAME --query "[].name" --output tsv)

    VM_ID=$(az vmss list-instances --resource-group $RESOURCE_GROUP --name $VMSS_NAME --query "[].id" --output tsv)

    az vmss run-command invoke \
    --resource-group $RESOURCE_GROUP \
    --instance-id $VM_ID \
    --vmss-name $VM_NAME \
    --instance-id $VM_NAME \
    --command-id RunPowerShellScript \
    --scripts @scripts/install-tour-of-heroes-angular.ps1 \
    --parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/v1.29.0/dist.zip"
done
