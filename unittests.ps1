#create a new VNET
$ResourceGroupName = "test-rg"

#creating VNET-1 in East US
$Location1 = "eastus"

Connect-AzAccount -TenantId "25dd58c6-88cf-4ebe-8870-f7c393c72c9b"
Get-AzContext

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId


New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
    -Name "MySubnet" `
    -AddressPrefix "10.0.1.0/24"

# 2. Create the VNET and include that Subnet
New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -Name "MyVNet" `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet $subnetConfig