# Load environment variables
source 00-variables.sh

# Create virtual network for the vms
source 01-create-vnet.sh

# Create the database vm
source 02-create-database-vm.sh

# Create the api vm
source 03-create-api-vm.sh

# Create the frontend vm
source 04-create-front-end-vm.sh

# Create a public load balancer for the frontend vm
source 05-create-public-lb-for-front-end.sh

# Tour of heroes API URL: http://tour-of-heroes-api-vm.uksouth.cloudapp.azure.com/api/hero
# Tour of heroes Web URL: http://tour-of-heroes-frontend-vm.uksouth.cloudapp.azure.com

# Clean up
source 06-cleanup.sh