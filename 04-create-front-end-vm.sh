echo -e "Create a frontend vm named $FRONTEND_VM_NAME with image $FRONTEND_VM_IMAGE"

FQDN_FRONTEND_VM=$(az vm create \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--image $FRONTEND_VM_IMAGE \
--admin-username $FRONTEND_VM_ADMIN_USERNAME \
--admin-password $FRONTEND_VM_ADMIN_PASSWORD \
--vnet-name $VNET_NAME \
--subnet $FRONTEND_SUBNET_NAME \
--public-ip-address-dns-name tour-of-heroes-frontend-vm \
--nsg $FRONTEND_VM_NSG_NAME \
--size $VM_SIZE --query "fqdns" -o tsv)

echo -e "Frontend vm created with FQDN $FQDN_FRONTEND_VM"

echo -e "Create a network security group rule for ssh port 22 for PSSession"
az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name AllowSsh \
--priority 1001 \
--destination-port-ranges 22 \
--direction Inbound

echo -e "Execute PowerShell"
pwsh

Write-Output "Install IIS on the frontend vm"
Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -name Web-Server -IncludeManagementTools'

Write-Output "Download URL Rewrite Module"
Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Invoke-WebRequest -Uri "https://www.microsoft.com/web/handlers/webpi.ashx?command=getinstallerredirect&appid=urlrewrite2" -OutFile C:\Temp\urlrewrite2.exe'

Write-Output "Install URL Rewrite Module"
Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'C:\Temp\urlrewrite2.exe /install /quiet'

Write-Output "Create a folder for the frontend app"
Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'mkdir C:\inetpub\wwwroot\frontend'

Write-Output "Download the last release of the frontend app from github"
Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Invoke-WebRequest -Uri "

