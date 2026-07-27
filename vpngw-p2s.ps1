#create a new VNET
$ResourceGroupName = "Sybex_Ch04_vpn-p2s-rg"

#creating VNET-1 in East US
$Location1 = "eastus2"

$VNetName1 = "vnet-eus-01"
$AddressPrefix1 = "10.0.0.0/16"

$SubnetName2 = "workloadSubnet"
$SubnetAddressPrefix2 = "10.0.2.0/24"
#vm-01 will be in "workloadSubnet" and this VM will not have any public ip.

$SubnetName3 = "GatewaySubnet"
$SubnetAddressPrefix3 = "10.0.0.0/27"
#VPN GW will be in East US.

#Connect to Azure
Connect-AzAccount -TenantId "25dd58c6-88cf-4ebe-8870-f7c393c72c9b"
Get-AzContext

$SubscriptionId = "ff62842a-5857-4d36-9ab5-4fe04c591ad2"
Select-AzSubscription -SubscriptionId $SubscriptionId

#The reasource group will be in East US.
New-AzResourceGroup -Name $ResourceGroupName -Location $Location1

<#
Create VNET with subnets
#>

function New-VNetEastUS {
    param (
        [string]$SubnetName2,
        [string]$SubnetAddressPrefix2,
        [string]$SubnetName3,
        [string]$SubnetAddressPrefix3,
        
        [string]$VNetName1,
        [string]$ResourceGroupName,
        [string]$Location1,
        [string]$AddressPrefix1
    )

    try {
        $workloadsubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName2 `
        -AddressPrefix $SubnetAddressPrefix2 `
        -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to create $($SubnetName2)." 
    }

    try {
        $gatewaysubnetconfigobj= New-AzVirtualNetworkSubnetConfig `
        -Name $SubnetName3 `
        -AddressPrefix $SubnetAddressPrefix3 `
        -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to create $($SubnetName3)." 
    }

    

    $VnetParameters = @{
        Name              = $VNetName1
        ResourceGroupName = $ResourceGroupName
        Location          = $Location1
        AddressPrefix     = $AddressPrefix1
        Subnet            = $workloadsubnetconfigobj, $gatewaysubnetconfigobj
    }

    
    try {
        $VirtualNetworkObj = New-AzVirtualNetwork @VnetParameters -ErrorAction Stop

        # Make things "permanent" in Azure!
        $VirtualNetworkObj | Set-AzVirtualNetwork    
    }
    catch {
        Write-Warning "Failed to create $($VNetName1)." 
    }
}

New-VNetEastUS -SubnetName2 $SubnetName2 `
            -SubnetAddressPrefix2 $SubnetAddressPrefix2 `
            -SubnetName3 $SubnetName3 `
            -SubnetAddressPrefix3 $SubnetAddressPrefix3 `
            -VNetName $VNetName1 `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location1 `
            -AddressPrefix $AddressPrefix1



$Vmname1 = "vm-01-vnet-eus-01"  #without public IP inside workloadSubnet of vnet-eus-01 
$Image = "Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest"

$username = "admanisulhuq" #enter username for all VM
$plainPassword = "McIe@4:5WmFvM" #enter password for VM
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$vmcred = New-Object System.Management.Automation.PSCredential ($username, $password)

function New-CustomVMInstance {
    param (
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

try {
        New-AzVM @vmParams        
    }
    catch {
        Write-Warning "Failed to create $($Vmname)." 
    }
}


New-CustomVMInstance -Vmname $Vmname1 `
           -VNetName $VNetName1 `
           -SubnetName $SubnetName2 `
           -ResourceGroupName $ResourceGroupName `
           -Location $Location1 `
           -Image $Image

<#
Now we create the VPN GW
#>
$GWPipName = "pip-vpn-eus"
$gwpip = New-AzPublicIpAddress -Name $GWPipName `
         -ResourceGroupName $ResourceGroupName `
         -Location $Location1 `
         -Sku Standard `
         -AllocationMethod Static `
         -Zone 1,2,3

write-Host "Public IP for VPN Gateway created: $($gwpip.IpAddress)" -ForegroundColor Green

#Get the VNET object for vnet-eus-01.
$VNetEastUSObj = Get-AzVirtualNetwork -Name $VNetName1 -ResourceGroupName $ResourceGroupName -ErrorAction Stop
write-Host "VNET Object for $($VNetEastUSObj.Name) retrieved." -ForegroundColor Green

$VNetEastUS_GWSubnetObj = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName3 -VirtualNetwork $VNetEastUSObj -ErrorAction Stop
Write-Host "Subnet Object for $($VNetEastUS_GWSubnetObj.Name) retrieved." -ForegroundColor Green
#  SubnetName3 which is the "GatewaySubnet" of vnet-eus-01


$gwipconfigObj = New-AzVirtualNetworkGatewayIpConfig -Name "vpngw-eus-01" `
                    -Subnet $VNetEastUS_GWSubnetObj `
                    -PublicIpAddress $gwpip

<#
https://learn.microsoft.com/en-us/powershell/module/az.network/new-azvirtualnetworkgateway?view=azps-16.0.0
#>

$entraTenantId = "25dd58c6-88cf-4ebe-8870-f7c393c72c9b"

$gwParams = @{
    Name              = "vpngw-eus-01"
    ResourceGroupName = $ResourceGroupName
    Location          = $Location1
    GatewayType       = "Vpn"
    VpnType           = "RouteBased"
    EnableBgp         = $false
    IpConfigurations  = $gwipconfigObj
    GatewaySku        = "VpnGw1AZ"

    # --- Add P2S Settings Directly into the Deployment ---
    VpnClientAddressPool = @("172.16.1.0/24")
    VpnClientProtocol = "OpenVPN"
    VpnAuthenticationType = "AAD"

    # Entra ID / Tenant Settings
    AadTenantUri = "https://login.microsoftonline.com/$entraTenantId"
    AadAudienceId = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
    AadIssuerUri = "https://sts.windows.net/$entraTenantId/"
}


New-AzVirtualNetworkGateway @gwParams -ErrorAction Stop