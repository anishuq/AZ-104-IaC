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

    $FWprivateAddress = $FWObj.IpConfigurations[0].privateipaddress
    Write-Host "FW private IP address:   $($FWprivateAddress)"

    # 1. Create the empty container in Azure
    $RTObj = New-AzRouteTable -ResourceGroupName $ResourceGroupName -Location $Location `
                              -Name $RTName -DisableBgpRoutePropagation 

    # 2. Add the route to your LOCAL variable ($RTObj)
    # Note: I'm capturing the output back into $RTObj to keep it updated
    $RTObj = Add-AzRouteConfig -Name "dg-to-firewall" `
                    -AddressPrefix "0.0.0.0/0" `
                    -NextHopType "VirtualAppliance" `
                    -NextHopIpAddress $FWprivateAddress `
                    -RouteTable $RTObj                         

    # 3. Push the local variable's data up to the actual Azure Resource
    Set-AzRouteTable -RouteTable $RTObj 
    #$RTObj | Set-AzRouteTable

    # 4. Now that the table actually HAS the route, attach it to the Subnet
    Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetObj -Name $vnetObj.Subnets[0].Name `
                                     -AddressPrefix $vnetObj.Subnets[0].AddressPrefix `
                                     -RouteTable $RTObj

    # 5. Push the VNet changes to Azure                                    
    Set-AzVirtualNetwork -VirtualNetwork $vnetObj 
    #$vnetObj | Set-AzVirtualNetwork


    $appRule01 = New-AzFirewallApplicationRule -Name "Allow-Google-Access" `
                                                -TargetFqdn "www.google.com" -Protocol "http:80", "https:443" `
                                                -SourceAddress $vnetObj.Subnets[0].AddressPrefix

    $appRuleCollection = New-AzFirewallApplicationRuleCollection -Name "AppRuleCollection" -Priority 100 `
                                                                -Rule $appRule01 -ActionType Allow

    $FWObj.ApplicationRuleCollections.Add($appRuleCollection)

    Set-AzFirewall -AzureFirewall $FWObj


    #Now we are going to create DNS rule for the workloadsubnet 
    $DNSnetRule01 = New-AzFirewallNetworkRule -Name "AllowDNSRule" -SourceAddress $vnetObj.Subnets[0].AddressPrefix `
                                                -DestinationPort 53 -Protocol UDP -DestinationAddress "8.8.8.8"

    $netRuleCollection = New-AzFirewallNetworkRuleCollection -Name "NetRuleCollection" -Priority 100 `
                                                                -Rule $DNSnetRule01 -ActionType Allow

    $FWObj.NetworkRuleCollections.Add($netRuleCollection)

    Set-AzFirewall -AzureFirewall $FWObj
}