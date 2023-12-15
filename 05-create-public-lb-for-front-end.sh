LOAD_BALANCER_NAME="tour-of-heroes-lb"
GREEN_IP_NAME="green-ip"
BLUE_IP_NAME="blue-ip"
PROBE_NAME="frontend-probe"
GREEN_BACKEND_POOL_NAME="green-backend-pool"
BLUE_BACKEND_POOL_NAME="blue-backend-pool"
TRAFFIC_MANAGER_NAME="tour-of-heroes-tm"

echo -e "Create a public IP"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name $GREEN_IP_NAME \
--sku Standard \
--dns-name $GREEN_IP_NAME

echo -e "Create a load balancer"

az network lb create \
--resource-group $RESOURCE_GROUP \
--name $LOAD_BALANCER_NAME \
--vnet-name $VNET_NAME \
--sku Standard \
--backend-pool-name $GREEN_BACKEND_POOL_NAME \
--frontend-ip-name $GREEN_IP_NAME \
--public-ip-address $GREEN_IP_NAME


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
--frontend-ip-name $GREEN_IP_NAME \
--backend-pool-name $GREEN_BACKEND_POOL_NAME \
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
--pool-name $GREEN_BACKEND_POOL_NAME \
--name $FRONTEND_VM_NAME \
--ip-address $FRONTEND_VM_PRIVATE_IP \
--vnet $VNET_NAME 

echo -e "Try to access the front end VM using the public IP address of the load balancer"

GREEN_LB_PUBLIC_IP=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $GREEN_IP_NAME \
--query ipAddress \
--output tsv)

echo -e "Green IP: http://$GREEN_LB_PUBLIC_IP"


echo -e "Create blue backend pool"

az network lb address-pool create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $BLUE_BACKEND_POOL_NAME

echo -e "Create blue public IP"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name $BLUE_IP_NAME \
--sku Standard \
--dns-name $BLUE_IP_NAME

az network lb address-pool create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $BLUE_BACKEND_POOL_NAME

echo -e "Add blue public IP to the load balancer"

az network lb frontend-ip create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name $BLUE_IP_NAME \
--public-ip-address $BLUE_IP_NAME

echo -e "Create blue load balancer rule"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule2 \
--protocol tcp \
--frontend-port 80 \
--backend-port 8080 \
--frontend-ip-name $BLUE_IP_NAME \
--backend-pool-name $BLUE_BACKEND_POOL_NAME \
--probe-name $PROBE_NAME \
--disable-outbound-snat true \
--idle-timeout 15

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
--parameters "api_url=http://$FQDN_API_VM/api/hero" "release_url=https://github.com/0GiS0/tour-of-heroes-web/releases/download/v2.0.0/dist.zip"


echo -e "Get front end VM 2 private IP address"

FRONTEND_VM_PRIVATE_IP_2=$(az vm show \
--resource-group $RESOURCE_GROUP \
--name "${FRONTEND_VM_NAME}-2" \
--show-details \
--query privateIps \
--output tsv)

echo -e "Add the frontend vm 2 to the blue backend pool"

az network lb address-pool address add  \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--pool-name $BLUE_BACKEND_POOL_NAME \
--name "${FRONTEND_VM_NAME}-2" \
--ip-address $FRONTEND_VM_PRIVATE_IP_2 \
--vnet $VNET_NAME

echo -e "Frontend VM 2 public IP address: http://$FQDN_FRONTEND_VM_2"
echo -e "Load balancer public IP address: http://$FRONTEND_LB_PUBLIC_IP"

# https://learn.microsoft.com/en-us/azure/load-balancer/distribution-mode-concepts

echo -e "Create a Traffic Manager profile"

az network traffic-manager profile create \
--resource-group $RESOURCE_GROUP \
--name $TRAFFIC_MANAGER_NAME \
--routing-method Weighted \
--unique-dns-name $TRAFFIC_MANAGER_NAME

echo -e "Create a Traffic Manager endpoint for the green backend pool"

GREEN_IP_ID=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $GREEN_IP_NAME \
--query id \
--output tsv)

az network traffic-manager endpoint create \
--resource-group $RESOURCE_GROUP \
--profile-name $TRAFFIC_MANAGER_NAME \
--name green \
--type azureEndpoints \
--target-resource-id $GREEN_IP_ID \
--endpoint-status Enabled \
--weight 500


BLUE_IP_ID=$(az network public-ip show \
--resource-group $RESOURCE_GROUP \
--name $BLUE_IP_NAME \
--query id \
--output tsv)

echo -e "Create a Traffic Manager endpoint for the blue backend pool"

az network traffic-manager endpoint create \
--resource-group $RESOURCE_GROUP \
--profile-name $TRAFFIC_MANAGER_NAME \
--name blue \
--type azureEndpoints \
--target-resource-id $BLUE_IP_ID \
--endpoint-status Enabled \
--weight 500

echo -e "Get Traffic Manager DNS name"

TRAFFIC_MANAGER_DNS_NAME=$(az network traffic-manager profile show \
--resource-group $RESOURCE_GROUP \
--name $TRAFFIC_MANAGER_NAME \
--query dnsConfig.fqdn \
--output tsv)

echo -e "Traffic Manager DNS name: http://$TRAFFIC_MANAGER_DNS_NAME"