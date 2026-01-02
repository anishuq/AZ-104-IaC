<#
This script creates two virtual networks in different regions and a jumpbox VM in one of the VNETs.
This is all in preparation for VNET peering. Though the peering itself is not created in this script.
#>

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
$Vmname2 = "vnet-eus-01-vm-01"  #without public IP
$Vmname3 = "vnet-wus-01-vm-01"  #without public IP
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

<#Username: admanisulhuq
Password: McIe@4:5WmFvM
Though this is not a secure password, this is just for lab purpose.
#>
$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)


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

    # Make things "permanent" in Azure!
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
         -Sku Basic

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
#This is the public IP for the jumpbox VM.
Create-VMs -pipName $JBpipName `
           -EnablePublicIP $true `
           -Vmname $Vmname1 `
           -VNetName $VNetName1 `
           -SubnetName $SubnetName1 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location1 `
           -Image $Image
        
#Creating VM in vnet-eus-01 without public IP

Create-VMs -pipName "" `
           -EnablePublicIP $false `
           -Vmname $Vmname2 `
           -VNetName $VNetName1 `
           -SubnetName $SubnetName1 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location1 `
           -Image $Image

#Creating VM in vnet-wus-01 without public IP
Create-VMs -pipName "" `
           -EnablePublicIP $false `
           -Vmname $Vmname3 `
           -VNetName $VNetName2 `
           -SubnetName $SubnetName2 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location2 `
           -Image $Image
           
Write-Host "All VMs deployed successfully!"