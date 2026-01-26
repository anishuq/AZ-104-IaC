<#
KEY POINTS:
Subnet First: Firewall needs a home (subnet) before it can be created

Public IP for the FW has to be created.

IP Assignment: Private IP assigned automatically during firewall creation

Route Table Direction: Routes TO the firewall, not FROM the firewall

Association: Route table associated with source subnets, not firewall subnet

Rules Last: Firewall rules can be configured anytime after creation
#>
Write-Host "FW Helper Loaded!"

function New-AzFWCreation{
    param(
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$FWPipName,
        [string]$FWName,
        [string]$RTName,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork]$vnetObj
    )

    #print all the params
    
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Host "Parameter '$key' was set to: $($PSBoundParameters[$key])"
    } 

    $FWPipObj = New-AzPublicIpAddress -Name $FWPipName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Static -Sku Standard


    $FWObj = New-AzFirewall -Name $FWName -ResourceGroupName $ResourceGroupName -Location $Location `
            -PublicIpAddress $FWPipObj -VirtualNetwork $vnetObj

    $FWprivateAddress = $FWObj.IpConfigurations.privateipaddress
    Write-Host "FW private IP address:   $($FWprivateAddress)"

    $RTObj = New-AzRouteTable -ResourceGroupName $ResourceGroupName -Location $Location `
                              -Name $RTName -DisableBgpRoutePropagation 

    Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetObj -Name $vnetObj.Subnets[0].Name `
                                     -AddressPrefix $vnetObj.Subnets[0].AddressPrefix `
                                     -RouteTable $RTObj

    $vnetObj | Set-AzVirtualNetwork
}