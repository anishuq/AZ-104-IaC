. "$PSScriptRoot/NetworkHelper.ps1"
. "$PSScriptRoot/PIPHelper.ps1"
. "$PSScriptRoot/VPNGWHelper.ps1"
. "$PSScriptRoot/LocalNetworkGWHelper.ps1"

$ResourceGroupName = "AZ104-NetworkWatcherVPNTroubleshoot"

$Location1 = "eastus"


#creating VNET-1 in East US
$VNetName = "NetworkWatcherVnet"
$AddressPrefix = "40.0.0.0/16"
$SubnetName1 = "GatewaySubnet"
$SubnetAddressPrefix1 = "40.0.0.0/27"
<#
There will be NO VMs created in this lab.
The purpose of this lab is to create a VNet with GatewaySubnet and 
then use Network Watcher VPN Troubleshoot to troubleshoot the connectivity issue.
#>

#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

#Create the VNets
$vnetObj = New-AzVNetSubnetsCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -vnetName $VNetName `
    -vnetAddressPrefix $AddressPrefix `
    -gatewaySubnetName $SubnetName1 `
    -gatewaySubnetPrefix $SubnetAddressPrefix1 
    
Write-Host "VNET obj type:  $($vnetObj.GetType().FullName)"

$vpnGWPipObj = New-AzPublicIPCreation -ResourceGroupName $ResourceGroupName `
                                -Location $Location1 `
                                -PipName "VPNGW-PIP" `
                                -Sku "Standard" `
                                -AllocationMethod "Static"

Write-Host "VPN PIP obj type:  $($vpnGWPipObj.GetType().FullName)"

$vpnGWObj = New-AzVPNGWCreation -vnetObj $vnetObj `
                                -vpnGWPipObj $vpnGWPipObj `
                                -ResourceGroupName $ResourceGroupName `
                                -Location $Location1 `
                                -VPNGWName "NetworkWatcherVPNGW"

Write-Host "VPN GW obj type:  $($vpnGWObj.GetType().FullName)"

#call LNGW and connection creation function. The on-prem public IP and address prefix are dummy values as we are not creating actual connection in this lab.