Write-Host "VPN GW Helper Loaded!"

function New-AzVPNGWCreation{
    param(
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetwork] $vnetObj,
        [Microsoft.Azure.Commands.Network.Models.PSPublicIpAddress] $vpnGWPipObj,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$VPNGWName
    )

    $VPNGWParameters = @{
        Name              = $VPNGWName
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
    }

    #Create the IP Config for the VPN Gateway. Why this is needed is explained
    #in the PS DOCS.
    $vpnGWIPConfigObj = New-AzVirtualNetworkGatewayIpConfig -Name "$VPNGWName-IPConfig" `
                 -SubnetId $vnetObj.Subnets[0].Id `
                 -PublicIpAddressId $vpnGWPipObj.Id 

    #Create the VPN Gateway
    $vpnGWObj = New-AzVirtualNetworkGateway @VPNGWParameters `
               -GatewayType "Vpn" -VpnType "RouteBased" `
               -GatewaySku "VpnGw1" `
               -IpConfigurations $vpnGWIPConfigObj

    Write-Host "VPN GW obj type:  $($vpnGWObj.GetType().FullName)"
    return $vpnGWObj
}