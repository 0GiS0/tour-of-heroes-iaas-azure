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

echo -e "Front end VM public IP address: http://$FRONTEND_LB_PUBLIC_IP"