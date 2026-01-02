<#
This script creates two virtual networks in different regions and a jumpbox VM in EastUS VNET.
EastUS VNET will have 3 subnets: jumpboxSubnet, workloadSubnet, and GatewaySubnet.
#>

#create a new VNET
$ResourceGroupName = "vpn-infra-rg"

#creating VNET-1 in East US
$Location1 = "eastus"

$VNetName1 = "vnet-eus-01"
$AddressPrefix1 = "10.0.0.0/16"

$SubnetName1 = "jumpboxSubnet"
$SubnetAddressPrefix1 = "10.0.1.0/24"

$SubnetName2 = "workloadSubnet"
$SubnetAddressPrefix2 = "10.0.2.0/24"

$SubnetName3 = "GatewaySubnet"
$SubnetAddressPrefix3 = "10.0.0.0/27"
############################################
#creating VNET-2 in West US

$Location2 = "westus"

$VNetName2 = "vnet-wus-01"
$AddressPrefix2 = "10.1.0.0/16"

$SubnetName4 = "workloadSubnet"
$SubnetAddressPrefix4 = "10.1.1.0/24"

$SubnetName5 = "GatewaySubnet"
$SubnetAddressPrefix5 = "10.1.0.0/27"
############################################

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1


function New-VNetEastUS {
    param (
        [string]$SubnetName1,
        [string]$SubnetAddressPrefix1,
        [string]$SubnetName2,
        [string]$SubnetAddressPrefix2,
        [string]$SubnetName3,
        [string]$SubnetAddressPrefix3,
        
        [string]$VNetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$AddressPrefix
    )

    $jumpboxsubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName1 `
        -AddressPrefix $SubnetAddressPrefix1

    $workloadsubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName2 `
        -AddressPrefix $SubnetAddressPrefix2

    $gatewaysubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName3 `
        -AddressPrefix $SubnetAddressPrefix3

    $VnetParameters = @{
        Name              = $VNetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $AddressPrefix
        Subnet            = $jumpboxsubnetconfigobj, $workloadsubnetconfigobj, $gatewaysubnetconfigobj
    }

    $VirtualNetworkObj = New-AzVirtualNetwork @VnetParameters

    # Make things "permanent" in Azure!
    $VirtualNetworkObj | Set-AzVirtualNetwork
}

New-VNetEastUS -SubnetName1 $SubnetName1 `
            -SubnetAddressPrefix1 $SubnetAddressPrefix1 `
            -SubnetName2 $SubnetName2 `
            -SubnetAddressPrefix2 $SubnetAddressPrefix2 `
            -SubnetName3 $SubnetName3 `
            -SubnetAddressPrefix3 $SubnetAddressPrefix3 `
            -VNetName $VNetName1 `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location1 `
            -AddressPrefix $AddressPrefix1

function New-VNetWestUS {
    param (
        [string]$SubnetName2,
        [string]$SubnetAddressPrefix2,
        [string]$SubnetName3,
        [string]$SubnetAddressPrefix3,
        
        [string]$VNetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$AddressPrefix
    )

    $workloadsubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName2 `
        -AddressPrefix $SubnetAddressPrefix2

    $gatewaysubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName3 `
        -AddressPrefix $SubnetAddressPrefix3

    $VnetParameters = @{
        Name              = $VNetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $AddressPrefix
        Subnet            = $workloadsubnetconfigobj, $gatewaysubnetconfigobj
    }

    $VirtualNetworkObj = New-AzVirtualNetwork @VnetParameters

    # Make things "permanent" in Azure!
    $VirtualNetworkObj | Set-AzVirtualNetwork
}

New-VNetWestUS -SubnetName2 $SubnetName4 `
            -SubnetAddressPrefix2 $SubnetAddressPrefix4 `
            -SubnetName3 $SubnetName5 `
            -SubnetAddressPrefix3 $SubnetAddressPrefix5 `
            -VNetName $VNetName2 `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location2 `
            -AddressPrefix $AddressPrefix2


<#
VNETS are created. Now we create the VMs.
#>

$Vmname1 = "jumpbox-vm-01"
$Vmname2 = "vm-01-vnet-eus-01"  #without public IP inside workloadSubnet of vnet-eus-01 
$Vmname3 = "vm-02-vnet-wus-01"  #without public IP inside workloadSubnet of vnet-wus-01
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

function Create-VMs {
    param (
        [string]$pipName,
        [boolean]$EnablePublicIP,
        [string]$Vmname,
        [string]$VNetName,
        [string]$SubnetName,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$Image
    )


#Common VM parameters for all VMs.
$vmParams = @{
    ResourceGroupName  = $ResourceGroupName
    Name               = $Vmname
    Location           = $Location
    Size               = "Standard_B1s"
    VirtualNetworkName = $VNetName
    SubnetName         = $SubnetName
    Image              = $Image
    Credential         = $vmcred
}

if ($EnablePublicIP) {
    Write-Host "Public IP enabled. Creating PIP and adding to configuration..." -ForegroundColor Cyan
    $pip = New-AzPublicIpAddress -Name $pipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -AllocationMethod Static `
         -Sku Basic `
         -DomainNameLabel "jumpbox-vm-vnet-eus-01" # Add this for FQDN

    $vmParams['PublicIpAddressName'] = $pip.Name
    $vmParams["OpenPorts"] = 22
}

else {
    Write-Host "Public IP not needed. Skipping..." -ForegroundColor Yellow
    # You can leave this empty, or add settings specific to private VMs
}
New-AzVM @vmParams
}

$JBpipName = "pip-jumpbox-vm-01"
#This is the public IP for the jumpbox VM inside vnet-eus-01 inside jumpboxSubnet
Create-VMs -pipName $JBpipName `
           -EnablePublicIP $true `
           -Vmname $Vmname1 `
           -VNetName $VNetName1 `
           -SubnetName $SubnetName1 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location1 `
           -Image $Image
        
#Creating VM in vnet-eus-01 without public IP inside its workloadSubnet

Create-VMs -pipName "" `
           -EnablePublicIP $false `
           -Vmname $Vmname2 `
           -VNetName $VNetName1 `
           -SubnetName $SubnetName2 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location1 `
           -Image $Image

#Creating VM in vnet-wus-01 without public IP inside its workloadSubnet
Create-VMs -pipName "" `
           -EnablePublicIP $false `
           -Vmname $Vmname3 `
           -VNetName $VNetName2 `
           -SubnetName $SubnetName4 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location2 `
           -Image $Image
           
Write-Host "All VMs deployed successfully!"

<#
Now we create the VNET Peering for vnet-wus-01.
This will be done programitacally.
#>

$GWPipName = "pip-vpn-wus"
$gwpip = New-AzPublicIpAddress -Name $GWPipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location2 `
         -Sku Standard `
         -AllocationMethod Static `
         -Tier Regional

write-Host "Public IP for VPN Gateway created: $($gwpip.IpAddress)" -ForegroundColor Green

#Get the VNET object for vnet-wus-01.
$VNetWestUSObj = Get-AzVirtualNetwork -Name $VNetName2 -ResourceGroupName $ResourceGroupName
write-Host "VNET Object for $($VNetWestUSObj.Name) retrieved." -ForegroundColor Green

$VNetWestUS_GWSubnetObj = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName5 -VirtualNetwork $VNetWestUSObj
Write-Host "Subnet Object for $($VNetWestUS_GWSubnetObj.Name) retrieved." -ForegroundColor Green
#  SubnetName5 which is the "GatewaySubnet" of vnet-wus-01

$gwipconfigObj = New-AzVirtualNetworkGatewayIpConfig -Name "vpngw-wus-01" `
                    -Subnet $VNetWestUS_GWSubnetObj `
                    -PublicIpAddress $gwpip

New-AzVirtualNetworkGateway -Name "vpngw-wus-01" `
    -ResourceGroupName $ResourceGroupName `
    -Location $Location2 `
    -GatewayType Vpn `
    -VpnType RouteBased `
    -EnableBgp $false `
    -IpConfigurations $gwipconfigObj `
    -GatewaySku VpnGw1
