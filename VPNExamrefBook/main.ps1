<#
This script will create a VM instance in a specified VNet and Subnet.

#>
. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"
. "$PSScriptRoot\PIPHelper.ps1"

# Define Resource Group Name
$ResourceGroupName = "AZ104-VPNGateway"

# Define Location
$Location1 = "eastus"

# Define VNet and Subnet parameters. This is only for the VM.
# The VNET and subnet for VPNGW has been created via the portal.
$VNetName1 = "vpnvnet"
$AddressPrefix1 = "99.0.0.0/24"


$SubnetName1 = "vnpsubnet"
$SubnetAddressPrefix1 = "99.0.0.0/24"

#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

#Create the VNets
$vnetObj = New-AzVNetSubnetsCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -vnetName $VNetName1 `
    -vnetAddressPrefix $AddressPrefix1 `
    -subnetName $SubnetName1 `
    -subnetPrefix $SubnetAddressPrefix1 
    
Write-Host "VNET obj type:  $($vnetObj.GetType().FullName)"

#Create the VM Instance that will work as VPN Server.
$Image = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4-5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

$VMName = "az104vpnserver"
$NicName = "az104vpnserver-nic01"

#create a PIP for the NIC
$pipObj = New-AzPublicIPCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -PipName "az104vpnserver-ip-01" `
    -Sku "Basic" `
    -AllocationMethod "Dynamic"


<#
$vmObj = New-AzVMInstanceCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -VMName $VMName `
    -VnetObj $vnetObj `
    -Image $Image `
    -NicName $NicName `
    -PublicIpAddress $pipObj `
    -Credential $vmcred 

Write-Host "VM obj type:  $($vmObj.GetType().FullName)" #>