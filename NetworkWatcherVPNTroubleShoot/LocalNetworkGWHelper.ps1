Write-Host "LNG Helper Loaded!"


function New-AzLNGWCreation{
    param(
        [string] $onPremPublicIP,
        [string] $onPremAddressPrefix,
        [Microsoft.Azure.Commands.Network.Models.PSVirtualNetworkGateway] $vpnGWObj,
        [string]$ResourceGroupName,
        [string]$Location,
        [string]$sharedKey
    )

    $LNGWParameters = @{
        Name              = $vpnGWObj.Name + "-LNGW"
        ResourceGroupName = $ResourceGroupName
        Location          = $Location
        GatewayIpAddress   = $onPremPublicIP
        AddressPrefix     = @($onPremAddressPrefix)
    }

    $LNGWObj = New-AzLocalNetworkGateway @LNGWParameters
    Write-Host "LNGW obj type:  $($LNGWObj.GetType().FullName)"
    #Create the connection between the VPN GW and LNGW
    
    $connectionParameters = @{
        Name = $vpnGWObj.Name + "-to-" + $LNGWObj.Name + "-Connection"
        ResourceGroupName = $ResourceGroupName
        Location = $Location
        VirtualNetworkGateway1 = $vpnGWObj
        LocalNetworkGateway2 = $LNGWObj
        ConnectionType = "IPsec"
        SharedKey = $sharedKey
    }
    $ConnectionObj = New-AzVirtualNetworkGatewayConnection @connectionParameters
    Write-Host "Connection obj type:  $($ConnectionObj.GetType().FullName)"

    return $ConnectionObj
}