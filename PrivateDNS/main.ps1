. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\PrivateDNSHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"

# Define Resource Group Name
$ResourceGroupName = "PrivateDNSZone-rg"

# Define Location
$Location1 = "eastus2"

# Define VNet and Subnet parameters
$VNetName1 = "DemoVNet1"
$AddressPrefix1 = "10.0.0.0/16"

$VNetName2 = "DemoVNet2"
$AddressPrefix2 = "192.168.0.0/16"


#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId


#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1


#Create the VNets
New-AzVNetsCreation -ResourceGroupName $ResourceGroupName `
                    -Location $Location1 `
                    -vnetName1 $VNetName1 `
                    -vnetAddressPrefix1 $AddressPrefix1 `
                    -vnetName2 $VNetName2 `
                    -vnetAddressPrefix2 $AddressPrefix2

Write-Host "Script Execution Completed!"
