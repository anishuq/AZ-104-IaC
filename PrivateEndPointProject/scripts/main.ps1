. "$PSScriptRoot\PaaSStorageAccountHelper.ps1"
. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\PrivateEndPointHelper.ps1"
. "$PSScriptRoot\VMCreationHelper.ps1"


$ResourceGroupName = "PrivateEndPoint-rg"
$Location = "canadacentral"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$VNetName = "vnet-can-01"
$AddressPrefix = "10.0.0.0/16"

$SubnetName = "PrivateEndpointSubnet"
$SubnetAddressPrefix = "10.0.1.0/24"

New-AzVNetSubnetCreation -ResourceGroupName $ResourceGroupName -Location $Location `
-vnetName $VNetName -vnetAddressPrefix $AddressPrefix `
-subnetName $SubnetName -subnetAddressPrefix $SubnetAddressPrefix `
 
# Generate a unique string for resource names
$uniqueString = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

$storageAccountObj = New-AzPaaSStorageAccount -ResourceGroupName $ResourceGroupName `
                            -Location $Location `
                            -uniqueString $uniqueString

New-AzPrivateEndpointCreation -ResourceGroupName $ResourceGroupName `
                            -Location $Location `
                            -vnetName $VNetName `
                            -subnetName $SubnetName `
                            -privateEndpointName "privateendpoint$uniqueString" `
                            -storageAccountId $storageAccountObj.Id



<#We need a VM inside the VNET to test the private endpoint connectivity. Let's create 
a VM inside the VNET and test the connectivity to the storage account using the private endpoint.#>

$Vmname = "vm-test-privateendpoint"
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
$pipName = "pip-vm-01"

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

New-AzVMCreation -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -VNetName $VNetName `
         -SubnetName $SubnetName `
         -Vmname $Vmname `
         -vmcred $vmcred `
         -pipName $pipName `
         -Image $Image