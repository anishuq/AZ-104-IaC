. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\ServiceEndPointHelper.ps1"


# Define Resource Group Name
$ResourceGroupName = "ServiceEndpoint-rg"

# Define Location
$Location1 = "eastus2"

# Define VNet and Subnet parameters
$VNetName1 = "DemoVNet1"
$AddressPrefix1 = "10.0.0.0/16"

$SubnetName1 = "SQL_subnet"
$SubnetAddressPrefix1 = "10.0.2.0/24"


#Create Connecttion to Azure Account
Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4-5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

testAccess

New-AzVNetSubnetCreation -ResourceGroupName $ResourceGroupName -Location $Location1 `
-vnetName $VNetName1 -vnetAddressPrefix $AddressPrefix1 `
-sqlSubnetName $SubnetName1 -sqlSubnetAddressPrefix $SubnetAddressPrefix1

testAccess

New-AzSqlServerWithServiceEndpoint -ResourceGroupName $ResourceGroupName `
-Location $Location1 -SqlServerName "demo-sqlserver-001" -Credential $vmcred `
-vnetName $VNetName1

testAccess