Write-Host "Network Helper Loaded!"


function New-AzVNetSubnetsCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$workLoadSubnetName,
        [string]$workLoadSubnetPrefix,
        [string]$FWSubnetName,
        [string]$FWSubnetPrefix,
        [string]$BastionSubnetName,
        [string]$BastionSubnetPrefix       
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 
      
    #crete the subnetconfigs
    $workloadSubnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $workLoadSubnetName -AddressPrefix $workLoadSubnetPrefix
    $FWSubnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $FWSubnetName -AddressPrefix $FWSubnetPrefix
    $BastionSubnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $BastionSubnetName -AddressPrefix $BastionSubnetPrefix

    $VNetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $workloadSubnetConfigObj, $FWSubnetConfigObj, $BastionSubnetConfigObj
        }

    #Create the VNet
    $vnetObj = New-AzVirtualNetwork @VNetParameters

    Write-Host "VNET obj type:  $($vnetObj.GetType().FullName)"

    return $vnetObj
}