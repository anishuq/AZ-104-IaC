
function New-AzPrivateEndpointCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$vnetName,
        [string]$subnetName,
        [string]$privateEndpointName,
        [string]$storageAccountId
    )
    Write-Host "Creating Private Endpoint: $($ResourceGroupName), $($Location), $($vnetName), $($subnetName), $($privateEndpointName), $($storageAccountId)"
    
    # Get the virtual network and subnet objects
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $vnetName
    $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName

    $privateConnection = New-AzPrivateLinkServiceConnection -Name "$privateEndpointName-connection" `
                                            -PrivateLinkServiceId $storageAccountId `
                                            -GroupIds @("blob") `
                                            -RequestMessage "This connection will be automatically approved."

    # Create the private endpoint
    $privateEndpoint = New-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName `
                                              -Location $Location `
                                              -Name $privateEndpointName `
                                              -SubnetId $subnet.Id `
                                              -PrivateLinkServiceConnection $privateConnection

    Write-Host "Private Endpoint created: $($privateEndpoint.Name)"

    return $privateEndpoint
}