LOAD_BALANCER_NAME="frontend-lb"
LB_IP_NAME="lb-ip"
PROBE_NAME="frontend-probe"
BACKEND_POOL_NAME="tour-of-heroes-backend-pool"

echo -e "Create a public IP"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name $LB_IP_NAME \
--sku Standard \
--dns-name $LB_IP_NAME

echo -e "Create a load balancer"

az network lb create \
--resource-group $RESOURCE_GROUP \
--name $LOAD_BALANCER_NAME \
--vnet-name $VNET_NAME \
--sku Standard \
--backend-pool-name $BACKEND_POOL_NAME \
--frontend-ip-name $LB_IP_NAME \
--public-ip-address $LB_IP_NAME


echo -e "Create a health probe"

az network lb probe create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $PROBE_NAME \
--protocol tcp \
--port 80

echo -e "Create a load balancer rule"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule \
--protocol tcp \
--frontend-port 80 \
--backend-port 80 \
--frontend-ip-name $LB_IP_NAME \
--backend-pool-name $BACKEND_POOL_NAME \
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
--pool-name $BACKEND_POOL_NAME \
--name $FRONTEND_VM_NAME \
--ip-address $FRONTEND_VM_PRIVATE_IP \
--vnet $VNET_NAME

echo -e "Create a frontend vm #2 named ${FRONTEND_VM_NAME}-2 with image $FRONTEND_VM_IMAGE"

FQDN_FRONTEND_VM_2=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-frontend-vm-2-bckp \
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
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip"


echo -e "Get front end VM 2 private IP address"

FRONTEND_VM_PRIVATE_IP_2=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--show-details \
--query privateIps \
--output tsv)


echo -e "Add the frontend vm to the backend pool"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name $BACKEND_POOL_NAME \
--name "${FRONTEND_VM_NAME}-2" \
--ip-address $FRONTEND_VM_PRIVATE_IP_2 \
--vnet $VNET_NAME 

echo -e "Load balancer IP address: http://$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $LB_IP_NAME \
--query ipAddress \
--output tsv)"
