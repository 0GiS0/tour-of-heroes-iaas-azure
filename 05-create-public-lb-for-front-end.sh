LOAD_BALANCER_NAME="front-end-lb"
PUBLIC_IP_NAME="lb-ip"
PROBE_NAME="fontend-probe"

echo -e "Create a public IP"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name $PUBLIC_IP_NAME \
--sku Standard

echo -e "Create a load balancer"

az network lb create \
--resource-group $RESOURCE_GROUP \
--name $LOAD_BALANCER_NAME \
--vnet-name $VNET_NAME \
--sku Standard \
--public-ip-address $PUBLIC_IP_NAME \
--frontend-ip-name frontend-ip \
--backend-pool-name frontend-backend-pool

echo -e "Create a health probe"

az network lb probe create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $PROBE_NAME \
--protocol tcp \
--port 8080

echo -e "Create a load balancer rule"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule \
--protocol tcp \
--frontend-port 80 \
--backend-port 8080 \
--frontend-ip-name frontend-ip \
--backend-pool-name frontend-backend-pool \
--probe-name $PROBE_NAME \
--disable-outbound-snat true \
--idle-timeout 15

echo -e "Get front end VM private IP address"

FRONTEND_VM_PRIVATE_IP=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--show-details \
--query privateIps \
--output tsv)

echo -e "Add the frontend vm to the backend pool"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name frontend-backend-pool \
--name tour-of-heroes-front-end-vm \
--ip-address $FRONTEND_VM_PRIVATE_IP \
--vnet $VNET_NAME 

echo -e "Try to access the front end VM using the public IP address of the load balancer"

FRONTEND_LB_PUBLIC_IP=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $PUBLIC_IP_NAME \
--query ipAddress \
--output tsv)

echo -e "Load balancer public IP address: http://$FRONTEND_LB_PUBLIC_IP"

echo -e "Create a frontend vm #2 named ${FRONTEND_VM_NAME}-2 with image $FRONTEND_VM_IMAGE"

FQDN_FRONTEND_VM_2=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-frontend-vm-2 \
--nsg "${FRONTEND_VM_NSG_NAME}-2" \
--size $VM_SIZE --query "fqdns" -o tsv)

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name "${FRONTEND_VM_NSG_NAME}-2" \
--name Allow8080 \
--priority 1003 \
--destination-port-ranges 8080 \
--direction Inbound

echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--command-id RunPowerShellScript \
--scripts @scripts/install-tour-of-heroes-angular.ps1 \
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/v2.0.1/dist.zip"


echo -e "Get front end VM 2 private IP address"

FRONTEND_VM_PRIVATE_IP_2=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--show-details \
--query privateIps \
--output tsv)

echo -e "Add the frontend vm 2 to the backend pool"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name frontend-backend-pool \
--name tour-of-heroes-front-end-vm-2 \
--ip-address $FRONTEND_VM_PRIVATE_IP_2 \
--vnet $VNET_NAME