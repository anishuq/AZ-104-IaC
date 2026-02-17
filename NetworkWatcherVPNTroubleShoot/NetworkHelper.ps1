
Write-Host "Network Helper Loaded!"

function New-AzVNetSubnetsCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$gatewaySubnetName,
        [string]$gatewaySubnetPrefix     
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
    } 

    #crete the subnetconfigs
    $gatewaySubnetConfigObj = New-AzVirtualNetworkSubnetConfig -Name $gatewaySubnetName -AddressPrefix $gatewaySubnetPrefix


    $VNetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $gatewaySubnetConfigObj
        }

    #Create the VNet
    
    $vnetObj = New-AzVirtualNetwork @VNetParameters
    

    Write-Host "VNET obj type 3rd time:  $($vnetObj.GetType().FullName)"
    return $vnetObj
}