$ResourceGroupName = "az104vnet-rg"
$Location = "East US"
$VNetName = "az104vnet01-new"
$AddressPrefix = "10.1.0.0/16"
$SubnetName = "FrontEndSubnet"
$SubnetAddressPrefix = "10.1.1.0/24"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location


$subnetconfigobj= New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetAddressPrefix

$VirtualNetworkObj = New-AzVirtualNetwork -Name $VNetName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $Location `
                    -AddressPrefix $AddressPrefix `
                    -Subnet $subnetconfigobj

$VirtualNetworkObj | Set-AzVirtualNetwork

Write-Host "Virtual Network deployed successfully!"