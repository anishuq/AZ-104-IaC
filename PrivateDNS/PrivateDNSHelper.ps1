Write-Host "Private DNS Helper Loaded!"

function New-AzPrivateDNSZoneCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$vnetObj1,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$vnetObj2,
        [string]$zoneName       
    )

    New-AzPrivateDnsZone -Name $zoneName -ResourceGroupName $ResourceGroupName

    Write-Host "Printing names: $($vnetObj1.Name) ..... $($vnetObj2.Name)"
     
    New-AzPrivateDnsVirtualNetworkLink -ZoneName $zoneName -ResourceGroupName $ResourceGroupName `
    -Name $vnetObj1.Name -VirtualNetwork $vnetObj1 -EnableRegistration

    New-AzPrivateDnsVirtualNetworkLink -ZoneName $zoneName -ResourceGroupName $ResourceGroupName `
    -Name $vnetObj2.Name -VirtualNetwork $vnetObj2 -EnableRegistration

}