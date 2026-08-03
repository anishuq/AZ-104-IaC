. "$PSScriptRoot\PaaSStorageAccountHelper.ps1"
. "$PSScriptRoot\NetworkHelper.ps1"


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