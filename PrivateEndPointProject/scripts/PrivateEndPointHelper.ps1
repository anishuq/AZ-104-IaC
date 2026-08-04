
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
                                            -GroupId @("blob") `
                                            -RequestMessage "This connection will be automatically approved."

    # Create the private endpoint
    $privateEndpoint = New-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName `
                                              -Location $Location `
                                              -Name $privateEndpointName `
                                              -Subnet $subnet `
                                              -PrivateLinkServiceConnection $privateConnection

    Write-Host "Private Endpoint created: $($privateEndpoint.Name)"

    #Now we do the VNET integration with the private endpoint. 
    $DNSZoneName = "privatelink.blob.core.windows.net" 
    #This name is NOT arbitary. This is the DNS zone name for the blob service of Azure Storage.
    $privateDnsZone = New-AzPrivateDnsZone -ResourceGroupName $ResourceGroupName `
                                           -Name $DNSZoneName

    New-AzPrivateDnsVirtualNetworkLink -ResourceGroupName $ResourceGroupName `
                                           -ZoneName $privateDnsZone.Name `
                                           -Name "$($vnetName)-link" `
                                           -VirtualNetworkId $vnet.Id
                                           
                                          

    $zoneConfigObj = New-AzPrivateDnsZoneConfig -Name "Storage-Config" `
                        -PrivateDnsZoneId $privateDnsZone.ResourceId
    
    New-AzPrivateDnsZoneGroup -ResourceGroupName $ResourceGroupName `
                            -PrivateEndpointName $privateEndpoint.Name `
                            -Name "Storage-Group" `
                            -PrivateDnsZoneConfig $zoneConfigObj
    
    Get-AzPrivateDnsRecordSet -ResourceGroupName $ResourceGroupName -ZoneName $privateDnsZone.Name -RecordType A

    return $privateEndpoint
}