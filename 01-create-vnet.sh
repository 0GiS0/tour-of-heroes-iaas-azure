echo -e "Creating resource group $RESOURCE_GROUP in $LOCATION"

az group create \
--name $RESOURCE_GROUP \
--location $LOCATION

echo -e "Creating virtual network $VNET_NAME with address prefix $VNET_ADDRESS_PREFIX and subnet $DB_SUBNET_NAME with address prefix $DB_SUBNET_ADDRESS_PREFIX"

az network vnet create \
--resource-group $RESOURCE_GROUP \
--name $VNET_NAME \
--address-prefixes $VNET_ADDRESS_PREFIX \
--subnet-name $DB_SUBNET_NAME \
--subnet-prefixes $DB_SUBNET_ADDRESS_PREFIX

echo -e "Creating subnets $API_SUBNET_NAME with address prefix $API_SUBNET_ADDRESS_PREFIX and $FRONTEND_SUBNET_NAME with address prefix $FRONTEND_SUBNET_ADDRESS_PREFIX"

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name $VNET_NAME \
--name $API_SUBNET_NAME \
--address-prefixes $API_SUBNET_ADDRESS_PREFIX

az network vnet subnet create \
--resource-group $RESOURCE_GROUP \
--vnet-name $VNET_NAME \
--name $FRONTEND_SUBNET_NAME \
--address-prefixes $FRONTEND_SUBNET_ADDRESS_PREFIX