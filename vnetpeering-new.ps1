#create a new VNET
$ResourceGroupName = "vnetpeering-rg"

$Location1 = "eastus"
$Location2 = "westus"

#creating VNET-1 in East US
$VNetName1 = "vnet-eus-01"
$AddressPrefix1 = "172.16.0.0/16"
$SubnetName1 = "vnet-eus-subnet-01"
$SubnetAddressPrefix1 = "172.16.0.0/24"


#creating VNET-2 in West US
$VNetName2 = "vnet-wus-01"
$AddressPrefix2 = "192.168.0.0/16"
$SubnetName2 = "vnet-wus-subnet-01"
$SubnetAddressPrefix2 = "192.168.0.0/24"

#creating jumpbox VM in vnet-eus-01  with public IP.
$Vmname1 = "jumpbox-vm-01"
$Image = "Ubuntu22LTS"


Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1


function Create-VNet {
    param (
        [string]$SubnetName,
        [string]$SubnetAddressPrefix,
        [string]$VNetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$AddressPrefix
    )

    #create VNET-1 in East US
    $subnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName `
        -AddressPrefix $SubnetAddressPrefix

    $VnetParameters = @{
        Name              = $VNetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $AddressPrefix
        Subnet            = $subnetconfigobj
    }

    $VirtualNetworkObj = New-AzVirtualNetwork @VnetParameters

    # Update the virtual network to ensure the subnet is created
    $VirtualNetworkObj | Set-AzVirtualNetwork
}


Create-VNet -SubnetName $SubnetName1 `
            -SubnetAddressPrefix $SubnetAddressPrefix1 `
            -VNetName $VNetName1 `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location1 `
            -AddressPrefix $AddressPrefix1



Create-VNet -SubnetName $SubnetName2 `
            -SubnetAddressPrefix $SubnetAddressPrefix2 `
            -VNetName $VNetName2 `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location2 `
            -AddressPrefix $AddressPrefix2


Write-Host "Virtual Network deployed successfully!"

#Create jumpbox VM in vnet-eus-01 with public IP.
function Create-VMs {
    param (
        [string]$pipName,
        [string]$Vmname,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$AddressPrefix
    )
$pip-jumpbox-vm-01 = New-AzPublicIpAddress -Name $pipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -AllocationMethod Static `
         -Sku Basic



New-AzVM -ResourceGroupName $ResourceGroupName `
         -Name $Vmname `
         -Location $Location `
         -Size "Standard_B1s" `
         -VirtualNetworkName $VNetName `
         -SubnetName $SubnetName `
         -PublicIpAddressName $pip-jumpbox-vm-01.Name `
         -OpenPorts 22 `
         -Image $Image `
         -Credential (Get-Credential)
}

$JBpipName = "pip-jumpbox-vm-01"