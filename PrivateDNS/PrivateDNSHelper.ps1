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
    <#
    Whatever the name of your VNet object is — that's what gets used as the link name here.
    So if your VNet is named vnet-eus, the link will also be named vnet-eus in the portal under 
    Private DNS Zone → Virtual Network Links.
    #>

    New-AzPrivateDnsVirtualNetworkLink -ZoneName $zoneName -ResourceGroupName $ResourceGroupName `
    -Name $vnetObj2.Name -VirtualNetwork $vnetObj2 -EnableRegistration

}