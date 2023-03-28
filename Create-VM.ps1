# Import the AzureRM modules
Import-Module AzureRM.Compute
Import-Module AzureRM.Storage
Import-Module AzureRM.Resources
Import-Module AzureRM.Network

# Prompt the user for input
$vmName = Read-Host "Enter a name for the virtual machine"
$vmSize = Read-Host "Enter the virtual machine size (e.g., Standard_DS1_v2)"
$resourceGroupName = Read-Host "Enter the name of the resource group to use"
$location = Read-Host "Enter the location for the virtual machine (e.g., eastus2)"

# Create the resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# Create the virtual network
$vnet = New-AzureRmVirtualNetwork -Name "myVnet" -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix "10.0.0.0/16"

# Create the subnet
$subnet = Add-AzureRmVirtualNetworkSubnetConfig -Name "mySubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet

# Create the public IP address
$pip = New-AzureRmPublicIpAddress -Name "myPublicIp" -ResourceGroupName $resourceGroupName -Location $location -AllocationMethod Dynamic

# Create the network interface
$nic = New-AzureRmNetworkInterface -Name "myNic" -ResourceGroupName $resourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

# Create the virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

# Set the OS disk properties
$osDiskName = $vmName + "OSDisk"
$osDiskUri = "https://" + $storageAccountName + ".blob.core.windows.net/vhds/" + $osDiskName + ".vhd"
$osDiskCaching = "ReadWrite"
$osDiskCreateOption = "FromImage"
$osDiskManagedDiskType = "Standard_LRS"
$osDisk = New-AzureRmDiskConfig -AccountType $osDiskManagedDiskType -Location $location -CreateOption $osDiskCreateOption -DiskSizeGB $osDiskSize -Caching $osDiskCaching -StorageAccountName $storageAccountName -Name $osDiskName

# Add the OS disk to the virtual machine configuration
$vmConfig = Set-AzureRmVMOSDisk -VM $vmConfig -ManagedDiskId $osDisk.Id -CreateOption $osDiskCreateOption -Windows

# Create the virtual machine
New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig -NetworkInterfaceName $nic.Name -Verbose
