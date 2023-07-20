echo -e "Create an api vm named $API_VM_NAME with image $API_VM_IMAGE"

az vm create \
--resource-group $RESOURCE_GROUP \
--name $API_VM_NAME \
--image $API_VM_IMAGE \
--admin-username $API_VM_ADMIN_USERNAME \
--admin-password $API_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $API_SUBNET_NAME \
--public-ip-address "" \
--nsg "" \
--size $VM_SIZE

echo -e "Api vm created"