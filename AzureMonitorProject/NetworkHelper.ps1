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
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key]) and Type: $($PSBoundParameters[$key].GetType().Name)"
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

    return $vnetObj
    }