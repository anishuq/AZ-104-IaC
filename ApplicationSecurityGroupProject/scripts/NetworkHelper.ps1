

function New-AzVNETandSubnets {
    param (
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VNetName,
        [string]$AddressPrefix,
        [string]$SubnetName1,
        [string]$SubnetAddressPrefix1,
        [string]$SubnetName2,
        [string]$SubnetAddressPrefix2
    )

     Write-Host "Creating VNet and Subnets: $($ResourceGroupName), $($Location), $($vnetName), $($jumpboxSubnetName), $($jumpboxAddressPrefix), $($webSubnetName), $($webAddressPrefix)"
     
     #create the subnetconfigs

     $webSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName1 `
            -AddressPrefix $SubnetAddressPrefix1

     $logicDBSubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName2 `
             -AddressPrefix $SubnetAddressPrefix2
   
    $VnetParameters = @{
        Name              = $VNetName       
        ResourceGroupName = $ResourceGroupName
        Location          = $Location   
        AddressPrefix     = $AddressPrefix
        Subnet            = $webSubnetConfig, $logicDBSubnetConfig      
    }
    $vnetObj = New-AzVirtualNetwork @VnetParameters
    
    return $vnetObj
}