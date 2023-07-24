# General variables
RESOURCE_GROUP="tour-of-heroes-on-vms"
LOCATION="westeurope"
VM_SIZE="Standard_B2s"

STORAGE_ACCOUNT_NAME="tourofheroesbackups"

# VNET variables
VNET_NAME="tour-of-heroes-vnet"
VNET_ADDRESS_PREFIX=192.168.0.0/16
DB_SUBNET_NAME="db-subnet"
DB_SUBNET_ADDRESS_PREFIX=192.168.1.0/24
API_SUBNET_NAME="api-subnet"
API_SUBNET_ADDRESS_PREFIX=192.168.2.0/24
FRONTEND_SUBNET_NAME="frontend-subnet"
FRONTEND_SUBNET_ADDRESS_PREFIX=192.168.3.0/24


# SQL Server VM on Azure
DB_VM_NAME="db-vm"
DB_VM_IMAGE="MicrosoftSQLServer:sql2022-ws2022:sqldev-gen2:16.0.230613"
DB_VM_ADMIN_USERNAME="dbadmin"
DB_VM_ADMIN_PASSWORD="Db@dmin123!$"
DB_VM_NSG_NAME="db-vm-nsg"

# API VM on Azure
API_VM_NAME="api-vm"
API_VM_IMAGE="UbuntuLTS"
API_VM_ADMIN_USERNAME="apiadmin"
API_VM_ADMIN_PASSWORD="Api@dmin1232!"
API_VM_NSG_NAME="api-vm-nsg"


# Frontend VM on Azure
FRONTEND_VM_NAME="frontend-vm"
FRONTEND_VM_IMAGE="MicrosoftWindowsServer:WindowsServer:2022-Datacenter:latest"
FRONTEND_VM_ADMIN_USERNAME="frontendadmin"
FRONTEND_VM_ADMIN_PASSWORD="fr0nt#nd@dmin123"
FRONTEND_VM_NSG_NAME="frontend-vm-nsg"

echo -e "Variables loaded from 00-variables.sh"