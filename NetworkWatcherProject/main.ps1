<#
VNet: NetworkWatcherVnet (10.0.0.0/16)
  └─ Subnet: default (10.0.0.0/24)
       ├─ NetworkWatcher1 (10.0.0.4)
       └─ NetworkWatcher2 (10.0.0.5)


NetworkWatcherSecurityGroup (NSG)
├─ Inbound Rules:
│   ├─ Allow RDP (3389) from your IP/AnySource - Priority 300
│   └─ Default rules (AllowVnetInBound, etc.)
│
└─ Outbound Rules:
    └─ Default rules (AllowInternetOutBound, etc.)

Inbound Security Rules:
┌──────────────┬──────────┬────────────┬──────────┬──────────┐
│ Priority     │ Name     │ Port       │ Protocol │ Action   │
├──────────────┼──────────┼────────────┼──────────┼──────────┤
│ 300          │ AllowRDP │ 3389       │ TCP      │ Allow    │
│ 310          │ AllowICMP│ *          │ ICMP     │ Allow    │
│ 320          │ AllowHTTP│ 80         │ TCP      │ Allow    │
└──────────────┴──────────┴────────────┴──────────┴──────────┘

#>

. "$PSScriptRoot/NetworkHelper.ps1"
. "$PSScriptRoot/VMInstanceHelper.ps1"

$ResourceGroupName = "AZ104-NetworkWatcher"

$Location1 = "eastus"


#creating VNET-1 in East US
$VNetName1 = "NetworkWatcherVnet"
$AddressPrefix1 = "10.0.0.0/16"
$SubnetName1 = "default"
$SubnetAddressPrefix1 = "10.0.0.0/24"


$Image = "MicrosoftWindowsServer:WindowsServer:2019-Datacenter:latest"

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


$vnetObj = New-AzVNetSubnetsCreation -ResourceGroupName $ResourceGroupName `
    -Location $Location1 `
    -vnetName $VNetName1 `
    -vnetAddressPrefix $AddressPrefix1 `
    -subnetName $SubnetName1 `
    -subnetPrefix $SubnetAddressPrefix1

Write-Host "VNET obj type 4th time:  $($vnetObj.GetType().FullName)"
Write-Host "DEBUG: Creating VNet $vnetName with Prefix $($vnetObj.AddressSpace.AddressPrefixes)"
#create VM instance in East US

for($i=1; $i -le 2; $i++){
    $VMName = "NetworkWatcher$i"
    $vmObj = New-AzVMInstanceCreation -ResourceGroupName $ResourceGroupName `
                                        -Location $Location1 `
                                        -VMName $VMName `
                                        -VnetObj $vnetObj `
                                        -Image $Image `
                                        -Credential $vmcred

    Write-Host "VM $i created with name: $($vmObj.Name) and location: $($vmObj.Location)"  
    
}
