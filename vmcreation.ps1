#create a new VNET
$ResourceGroupName = "az104NSGtest-rg"
$Location = "canadacentral"
$VNetName = "vnet-eus-02"
$AddressPrefix = "172.16.0.0/16"
$SubnetName = "subnet-01"
$SubnetAddressPrefix = "172.16.1.0/24"

$Vmname = "vm-01"
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"
$pipName = "pip-vm-01"

Connect-AzAccount

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name $ResourceGroupName -Location $Location

$subnetconfigobj= New-AzVirtualNetworkSubnetConfig `
    -Name $SubnetName `
    -AddressPrefix $SubnetAddressPrefix

$VirtualNetworkObj = New-AzVirtualNetwork -Name $VNetName `
                    -ResourceGroupName $ResourceGroupName `
                    -Location $Location `
                    -AddressPrefix $AddressPrefix `
                    -Subnet $subnetconfigobj

$VirtualNetworkObj | Set-AzVirtualNetwork


$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

$pip = New-AzPublicIpAddress -Name $pipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location `
         -AllocationMethod Static `
         -Sku Basic



New-AzVM -ResourceGroupName $ResourceGroupName `
         -Name $Vmname `
         -Location $Location `
         -Size "Standard_B1s" `
         -VirtualNetworkName $VNetName `
         -SubnetName $SubnetName `
         -PublicIpAddressName $pip.Name `
         -OpenPorts 22 `
         -Image $Image `
         -Credential $vmcred



Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Vmname
Write-Host "Virtual Network and VM deployed successfully!"