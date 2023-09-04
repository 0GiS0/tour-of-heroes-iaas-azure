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