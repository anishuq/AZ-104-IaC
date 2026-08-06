. "$PSScriptRoot\NetworkHelper.ps1"
. "$PSScriptRoot\VMInstanceHelper.ps1"
. "$PSScriptRoot\ASGHelper.ps1"
. "$PSScriptRoot\NSGHelper.ps1"


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

$webVMObj = New-AzVMCreation -Vmname "webvm01" -VNetName $VNetName -SubnetName $SubnetName1 `
            -ResourceGroupName $ResourceGroupName -Location $Location -Image $Image `
            -Credential $vmcred -EnablePublicIP $true

#Create the ASG and associate it with the web VM NIC
$webASGObj = New-AzASGCreation -ASGName "webASG" -ResourceGroupName $ResourceGroupName `
            -Location $Location -VMobj $webVMObj


#Rule to allow incoming traffic from the internet to the web VM using webASG on port 80 (HTTP)            
$webRule = New-AzNetworkSecurityRuleConfig -Name "AllowInternet" -Description "Allow Internet incoming" `
            -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
            -SourceAddressPrefix * -SourcePortRange * `
            -DestinationApplicationSecurityGroupId $webASGObj.Id -DestinationPortRange 80
Write-Host "Rule type: $($webRule.GetType().FullName)" -ForegroundColor Green

$logicVMObj = New-AzVMCreation -Vmname "logicvm01" -VNetName $VNetName -SubnetName $SubnetName2 `
            -ResourceGroupName $ResourceGroupName -Location $Location -Image $Image `
            -Credential $vmcred -EnablePublicIP $false

#Create the ASG and associate it with the web VM NIC
$logicASGObj = New-AzASGCreation -ASGName "logicASG" -ResourceGroupName $ResourceGroupName `
            -Location $Location -VMobj $logicVMObj


$dbVMObj = New-AzVMCreation -Vmname "dbvm01" -VNetName $VNetName -SubnetName $SubnetName2 `
            -ResourceGroupName $ResourceGroupName -Location $Location -Image $Image `
            -Credential $vmcred -EnablePublicIP $false

#Create the ASG and associate it with the web VM NIC
$dbASGObj = New-AzASGCreation -ASGName "dbASG" -ResourceGroupName $ResourceGroupName `
            -Location $Location -VMobj $dbVMObj

#Allow Traiic from logicASG to dbASG on port 1433 (SQL Server)
$dbRule = New-AzNetworkSecurityRuleConfig -Name "AllowLogicToDB" -Description "Allow from Logic into DB" `
            -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
            -SourceApplicationSecurityGroupId $logicASGObj.Id -SourcePortRange * `
            -DestinationApplicationSecurityGroupId $dbASGObj.Id -DestinationPortRange 1433


<#Deny all other traffic headed to PORT 1433 (SQL Server) on dbVM. 
This will deny all other traffic to the dbASG except for traffic from logicASG on port 1433. #>
$denyRule = New-AzNetworkSecurityRuleConfig -Name "DenyAllOtherTraffic" -Description "Deny all other traffic to dbASG" `
            -Access Deny -Protocol * -Direction Inbound -Priority 120 `
            -SourceAddressPrefix * -SourcePortRange * `
            -DestinationApplicationSecurityGroupId $dbASGObj.Id -DestinationPortRange 1433


New-AzNSGCreation -NSGName "dbNSG" -ResourceGroupName $ResourceGroupName `
            -Location $Location -webRuleObj $webRule -dbRuleObj $dbRule -denyRuleObj $denyRule


Write-Host "VMs type: $($dbVMObj.GetType().FullName)" -ForegroundColor Green