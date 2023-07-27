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

# echo -e "Create a network security group rule for ssh port 22 for PSSession"
# az network nsg rule create \
# --resource-group $RESOURCE_GROUP \
# --nsg-name $FRONTEND_VM_NSG_NAME \
# --name AllowSsh \
# --priority 1001 \
# --destination-port-ranges 22 \
# --direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name AllowHttp \
--priority 1002 \
--destination-port-ranges 80 \
--direction Inbound

az network nsg rule create \
--resource-group $RESOURCE_GROUP \
--nsg-name $FRONTEND_VM_NSG_NAME \
--name Allow8080 \
--priority 1003 \
--destination-port-ranges 8080 \
--direction Inbound

echo -e "Execute script to install IIS and deploy tour-of-heroes-angular SPA"
az vm run-command invoke \
--resource-group $RESOURCE_GROUP \
--name $FRONTEND_VM_NAME \
--command-id RunPowerShellScript \
--scripts @scripts/install-tour-of-heroes-angular.ps1

# echo -e "Install PowerShell on macOS"
# brew reinstall --cask powershell

# echo -e "Execute PowerShell"
# pwsh

# Write-Output "Load variables"
# $RESOURCE_GROUP = "tour-of-heroes-on-vms"
# $FRONTEND_VM_NAME = "frontend-vm"

# Write-Output "Install IIS on the frontend vm"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -name Web-Server -IncludeManagementTools'

# Write-Output "Download URL Rewrite Module"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Invoke-WebRequest -Uri "https://www.microsoft.com/web/handlers/webpi.ashx?command=getinstallerredirect&appid=urlrewrite2" -OutFile C:\Temp\urlrewrite2.exe'

# Write-Output "Install URL Rewrite Module"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'C:\Temp\urlrewrite2.exe /install /quiet'

# Write-Output "Create a folder for the frontend app"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'mkdir $env:systemdrive\inetpub\wwwroot\frontend'

# Write-Output "Download the last release of the frontend app from github"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Invoke-WebRequest -Uri https://github.com/0GiS0/tour-of-heroes-angular/releases/download/1.1.4/dist.zip -OutFile C:\Temp\dist.zip'

# Write-Output "Unzip the frontend app in the folder"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'Expand-Archive -Path C:\Temp\dist.zip -DestinationPath C:\inetpub\wwwroot\frontend'

# Write-Output "Create a new website in IIS"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'New-IISSite -Name "TourOfHeroesAngular" -BindingInformation "*:8080:" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"'

# Write-Output "Create an aplication inside the new site"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'New-WebApplication -Name "TourOfHeroesAngular" -Site "TourOfHeroesAngular" -ApplicationPool "TourOfHeroesAngular" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\frontend"'

# Write-Output "Enable 8080 port in the firewall"
# Invoke-AzVMRunCommand -Name $FRONTEND_VM_NAME -ResourceGroupName $RESOURCE_GROUP -CommandId 'RunPowerShellScript' -ScriptString 'New-NetFirewallRule -DisplayName "Allow 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow'