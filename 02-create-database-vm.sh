echo -e "Create a database vm named $DB_VM_NAME with image $DB_VM_IMAGE"
az vm create \
--resource-group $RESOURCE_GROUP \
--name $DB_VM_NAME \
--image $DB_VM_IMAGE \
--admin-username $DB_VM_ADMIN_USERNAME \
--admin-password $DB_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $DB_SUBNET_NAME \
--public-ip-address "" \
--size $VM_SIZE \
--nsg $DB_VM_NSG_NAME 

echo -e "Create a storage acount for the backups"
az storage account create \
--name $STORAGE_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--sku Standard_LRS \
--kind StorageV2

STORAGE_KEY=$(az storage account keys list \
--resource-group $RESOURCE_GROUP \
--account-name $STORAGE_ACCOUNT_NAME \
--query "[0].value" \
--output tsv)

echo -e "Add SQL Server extension to the database vm"
az sql vm create \
--name $DB_VM_NAME \
--license-type payg \
--resource-group $RESOURCE_GROUP \
--location $LOCATION \
--connectivity-type PRIVATE \
--port 1433 \
--sql-auth-update-username $DB_VM_ADMIN_USERNAME \
--sql-auth-update-pwd $DB_VM_ADMIN_PASSWORD \
--backup-schedule-type manual \
--full-backup-frequency Weekly \
--full-backup-start-hour 2 \
--full-backup-duration 2 \
--storage-account "https://$STORAGE_ACCOUNT_NAME.blob.core.windows.net/" \
--sa-key $STORAGE_KEY \
--retention-period 30 \
--log-backup-frequency 60

echo -e "Database vm created"

echo -e "Create a network security group rule for SQL Server port 1433"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $DB_VM_NSG_NAME \
--name AllowSQLServer \
--priority 1001 \
--destination-port-ranges 1433 \
--protocol Tcp \
--source-address-prefixes $API_SUBNET_ADDRESS_PREFIX \
--direction Inbound

# echo -e "Create a network security group rule for RDP port 3389"
# az network nsg rule create \
# --resource-group $RESOURCE_GROUP \
# --nsg-name $DB_VM_NSG_NAME \
# --name AllowRDP \
# --priority 1002 \
# --destination-port-ranges 3389 \
# --direction Inbound

# echo -e "Associate the network security group to the database vm"
# az network nic update \
# --resource-group $RESOURCE_GROUP \
# --name "${DB_VM_NAME}VMNic" \
# --network-security-group $DB_VM_NSG_NAME