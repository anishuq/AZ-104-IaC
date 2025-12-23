#create a new VNET
$ResourceGroupName = "az104vnet-rg"
$Location = "CanadaCentral"
$VNetName = "vnet-eus-02"
$AddressPrefix = "172.16.0.0/16"
$SubnetName = "subnet-01"
$SubnetAddressPrefix = "172.16.1.0/24"

$Vmname = "vm-01"
$Image = "UbuntuLTS"
$pipName = "pip-vm-01"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#the resource group already exists.

$subnetconfigobj= New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetAddressPrefix

$VirtualNetworkObj = New-AzVirtualNetwork -Name $VNetName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $Location `
                    -AddressPrefix $AddressPrefix `
                    -Subnet $subnetconfigobj

$VirtualNetworkObj | Set-AzVirtualNetwork


<#
VM user name: adm.anisulhuq
VM password: McIe@4:5WmFvM
#>
$pip = New-AzPublicIpAddress -Name $pipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -AllocationMethod Static `
         -Sku Standard



New-AzVM -ResourceGroupName $ResourceGroupName `
         -Name $Vmname `
         -Location $Location `
         -Size "Standard_B1s" `
         -VirtualNetworkName $VNetName `
         -SubnetName $SubnetName `
         -PublicIpAddressName $pipName `
         -Image $Image `
         -Credential (Get-Credential)



Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Vmname
Write-Host "Virtual Network and VM deployed successfully!"