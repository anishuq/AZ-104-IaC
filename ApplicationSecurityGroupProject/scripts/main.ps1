. "$PSScriptRoot\NetworkHelper.ps1"
#. "$PSScriptRoot\VMInstanceHelper.ps1"


# Define Resource Group Name
$ResourceGroupName = "ApplicationSecurityGroup-rg"

# Define Location
$Location = "canadacentral"

# Define VNet and Subnet parameters
$VNetName = "vnet-canadacentral-01"
$AddressPrefix = "10.0.0.0/16"

$SubnetName1 = "WebSubnet"
$SubnetAddressPrefix1 = "10.0.1.0/24"

$SubnetName2 = "LogicDBSubnet"
$SubnetAddressPrefix2 = "10.0.2.0/24"


#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

#Create the VNET and Subnets
$vnetObj = New-AzVNETandSubnets -ResourceGroupName $ResourceGroupName `
                                 -Location $Location -VNetName $VNetName `
                                 -AddressPrefix $AddressPrefix `
                                 -SubnetName1 $SubnetName1 -SubnetAddressPrefix1 $SubnetAddressPrefix1 `
                                 -SubnetName2 $SubnetName2 -SubnetAddressPrefix2 $SubnetAddressPrefix2   


#Choose an image for the VM: Ubuntu Server 22.04 LTS
Write-Host "Creating VMS now..." -ForegroundColor Green

$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4-5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)