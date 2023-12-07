LOAD_BALANCER_NAME="front-end-lb"

echo -e "Create a public IP"

az network public-ip create \
--resource-group $RESOURCE_GROUP \
--name lb-public-ip \
--sku Standard \
--zone 1

echo -e "Create a load balancer"

az network lb create \
--resource-group $RESOURCE_GROUP \
--name $LOAD_BALANCER_NAME \
--sku Standard \
--public-ip-address lb-public-ip \
--frontend-ip-name frontend-ip \
--backend-pool-name frontend-backend-pool

echo -e "Create a health probe"

az network lb probe create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name http-probe \
--protocol http \
--port 80 \
--path / 

echo -e "Create a load balancer rule"

az network lb rule create \
--resource-group $RESOURCE_GROUP \
--lb-name $LOAD_BALANCER_NAME \
--name myHTTPRule \
--protocol tcp \
--frontend-port 80 \
--backend-port 80 \
--frontend-ip-name frontend-ip \
--backend-pool-name frontend-backend-pool \
--probe-name http-probe \
--disable-outbound-snat true \
--idle-timeout 15 \
--enable-tcp-reset true

echo -e "Add the frontend vm to the backend pool"

az network nic ip-config address-pool add \
--resource-group $RESOURCE_GROUP \
--nic-name "${FRONTEND_VM_NAME}VMNic" \
--ip-config-name ipconfig1 \
--lb-name $LOAD_BALANCER_NAME \
--address-pool frontend-backend-pool

