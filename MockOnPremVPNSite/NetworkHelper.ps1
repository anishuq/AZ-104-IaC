Write-Host "Network Helper Loaded!"
function New-AzVNetSubnetsCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$subnetName,
        [string]$subnetPrefix     
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 
      
    #crete the subnetconfigs
    $subnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix
    
    $VNetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $subnetConfigObj
        }

    #Create the VNet
    $vnetObj = New-AzVirtualNetwork @VNetParameters

    Write-Host "VNET obj type 1st time:  $($vnetObj.GetType().FullName)"

    #attach NSG rule with the subnet to allow 3389     
    $rdpRule = New-AzNetworkSecurityRuleConfig -Name "nsgRule1" `
        -Protocol "Tcp" `
        -Direction "Inbound" `
        -Priority 100 `
        -SourceAddressPrefix "*" `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange 3389 `
        -Access "Allow"

    $nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName `
        -Location $Location `
        -Name "az104vpnserver-nsg-01" `
        -SecurityRules $rdpRule

    <#
    When you run Set-AzVirtualNetworkSubnetConfig, 
    the cmdlet does not return a "Subnet" object; 
    it returns the entire modified Virtual Network object.
    #>    
    $vnetObj = Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetObj `
        -Name $vnetObj.Subnets[0].Name `
        -AddressPrefix $vnetObj.Subnets[0].AddressPrefix `
        -NetworkSecurityGroup $nsg  

    $vnetObj = Set-AzVirtualNetwork -VirtualNetwork $vnetObj
    Write-Host "VNET obj type 2nd time:  $($vnetObj.GetType().FullName)"    

    return $vnetObj
}