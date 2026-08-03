Write-Host "Network Helper Loaded!"


function New-AzVNetSubnetCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$subnetName,
        [string]$subnetAddressPrefix
    )
    Write-Host "Creating VNet and Subnets: $($ResourceGroupName), $($Location), $($vnetName), $($vnetAddressPrefix), $($subnetName), $($subnetAddressPrefix)"
    #crete the subnetconfigs
    
    $privateSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName `
    -AddressPrefix $subnetAddressPrefix

    
    $VnetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $privateSubnetConfig
    }
    #create the VNET   
    $vnetObj = New-AzVirtualNetwork @VnetParameters

}