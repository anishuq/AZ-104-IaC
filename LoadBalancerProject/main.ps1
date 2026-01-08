. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"

# Define Resource Group Name
$ResourceGroupName = "LoadBalancer-rg"

# Define Location
$Location1 = "eastus"

# Define VNet and Subnet parameters
$VNetName1 = "vnet-eus-01"
$AddressPrefix1 = "10.0.0.0/16"

$SubnetName1 = "jumpboxSubnet"
$SubnetAddressPrefix1 = "10.0.1.0/24"

$SubnetName2 = "webSubnet"
$SubnetAddressPrefix2 = "10.0.2.0/24"

#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1



New-AzVNetSubnetCreation -ResourceGroupName $ResourceGroupName -Location $Location1 `
-vnetName $VNetName1 -vnetAddressPrefix $AddressPrefix1 `
-jumpboxSubnetName $SubnetName1 -jumpboxAddressPrefix $SubnetAddressPrefix1 `
-webSubnetName $SubnetName2 -webAddressPrefix $SubnetAddressPrefix2 

#VM creation parameters
#Choose an image for the VM: Ubuntu Server 22.04 LTS
Write-Host "Creating VMS now..." -ForegroundColor Green

$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)
$jumpboxVMName = "jumpbox-vm"


#First, create the jumpbox VM with public IP
New-AzVMCreation -pipName "jumpbox-pip" -EnablePublicIP $true `
-Vmname $jumpboxVMName -VNetName $VNetName1 -SubnetName $SubnetName1 `
-ResourceGroupName $ResourceGroupName -Location $Location1 `
-Image $Image -Credential $vmcred 