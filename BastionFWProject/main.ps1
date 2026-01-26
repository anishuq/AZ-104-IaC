. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\BastionHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"
. "$PSScriptRoot\PipHelper.ps1"
. "$PSScriptRoot\FWHelper.ps1"

# Define Resource Group Name
$ResourceGroupName = "BastionFW-rg"

# Define Location
$Location1 = "eastus2"

# Define VNet and Subnet parameters
$VNetName1 = "BastionFWVNet"
$AddressPrefix1 = "10.0.0.0/16"


$SubnetName1 = "WorkLoad_subnet"
$SubnetAddressPrefix1 = "10.0.0.0/24"


$SubnetName2 = "AzureBastionSubnet"
$SubnetAddressPrefix2 = "10.0.1.0/27"


$SubnetName3 = "AzureFirewallSubnet"
$SubnetAddressPrefix3 = "10.0.2.0/26"

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
    -workLoadSubnetName $SubnetName1 `
    -workLoadSubnetPrefix $SubnetAddressPrefix1 `
    -FWSubnetName $SubnetName3 `
    -FWSubnetPrefix $SubnetAddressPrefix3 `
    -BastionSubnetName $SubnetName2 `
    -BastionSubnetPrefix $SubnetAddressPrefix2


#Create the VM Instance in the Workload Subnet
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4-5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)
$VMName = "workloadvm"

$vmObj = New-AzVMInstanceCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -VMName $VMName `
    -VNetName $vnetObj.Name `
    -SubnetName $vnetObj.Subnets[0].Name `
    -Image $Image `
    -Credential $vmcred


#Create the Bastion
<# Takes a long time, hence stopped for a bit.
$bastionObj = New-AzBastionCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -BastionName "MyBastionHost" `
    -VNetObj $vnetObj 
#>

#create FW
New-AzFWCreation -ResourceGroupName $ResourceGroupName -Location $Location1 `
                -FWPipName "FwPip" -FWName "EgressFW" -RTName "RTEgress" -vnetObj $vnetObj