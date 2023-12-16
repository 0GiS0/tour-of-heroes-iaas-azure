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
--port 8080

echo -e "Create a load balancer rule"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule \
--protocol tcp \
--frontend-port 80 \
--backend-port 8080 \
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
