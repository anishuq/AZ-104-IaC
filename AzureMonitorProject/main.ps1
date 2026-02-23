. "$PSScriptRoot/NetworkHelper.ps1"
. "$PSScriptRoot/VMInstanceHelper.ps1"

$ResourceGroupName = "AZ104-Monitor"

$Location1 = "eastus"

$VmName = "MonitorServer"
#creating VNET-1 in East US
$VNetName1 = "MonitorVnet"
$AddressPrefix1 = "40.0.0.0/16"
$SubnetName1 = "MonitorSubnet"
$SubnetAddressPrefix1 = "40.0.0.0/24"


<# We are not going to use any particular Image. Instead the default Windows Server 2022 Datacenter 
will be used.
#>
<#Username: admanisulhuq
Password: McIe@4:5WmFvM
Though this is not a secure password, this is just for lab purpose.
#>
$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmCred = New-Object System.Management.Automation.PSCredential ($username, $password)


Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

$vnetObj = New-AzVNetSubnetsCreation -ResourceGroupName $ResourceGroupName `
                            -Location $Location1 `
                            -vnetName $VNetName1 `
                            -vnetAddressPrefix $AddressPrefix1 `
                            -subnetName $SubnetName1 `
                            -subnetPrefix $SubnetAddressPrefix1  

Write-Host "VNET obj type 2nd time:  $($vnetObj.GetType().FullName)"


$vmObj = New-AzVMInstanceCreation -ResourceGroupName $ResourceGroupName `
                                    -Location $Location1 `
                                    -VMName $VmName `
                                    -VnetObj $vnetObj `
                                    -Credential $vmCred

Write-Host "VM obj type:  $($vmObj.GetType().FullName)"
