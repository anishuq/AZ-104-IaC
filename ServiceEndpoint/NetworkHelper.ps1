Write-Host "Network Helper Loaded!"


function New-AzVNetSubnetCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$vnetAddressPrefix,
        [string]$sqlSubnetName,
        [string]$sqlSubnetAddressPrefix       
    )
    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    }
      
    #crete the subnetconfigs
    
    $sqlSubnetNameConfig = New-AzVirtualNetworkSubnetConfig -Name $sqlSubnetName `
    -AddressPrefix $sqlSubnetAddressPrefix
    

    $VnetParameters = @{
        Name              = $vnetName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        AddressPrefix     = $vnetAddressPrefix
        Subnet            = $sqlSubnetNameConfig
    }    

    #create the VNET   
    $vnetObj = New-AzVirtualNetwork @VnetParameters

    Write-Host "The VNET $vnetName has been created in the resource group $ResourceGroupName might remain hidden in the portal and the only way to see it is to get the canonical Resource ID of the VNET"
    $vnetResourceID = $vnetObj.Id
    $vnetPortalLink= "https://portal.azure.com/#resource"+$vnetResourceID
    Write-Host "The portal link of the VNET is: $vnetPortalLink .. use this to access the VNET"
}